(**
 * @file Yaml.pas
 * @brief Thick binding to libyaml (import/export to CVariant)
 *)

unit Yaml;

interface

uses
  SysUtils, Classes, Types, YamlIntermediate, YamlDelphiFeatures,
  CVariants;

{$INCLUDE 'YamlDelphiFeatures.inc'}

{$IFNDEF DELPHI_HAS_RECORDS}
{$WARN UNSAFE_TYPE OFF} // CVariant
{$ENDIF}


function FromYaml(const S: UTF8String): CVariant;

implementation

uses Math;

function MatchStringSet(const S: YamlString; const SSet: array of YamlString): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := Low(SSet) to High(SSet) do
    if S = SSet[i] then
    begin
      Result := True;
      Exit;
    end;
end;

function TryYamlScalarToInt(const S: YamlString; var R: CVariant): Boolean;
var
  i, j, k, L: Integer;
  IntRes: Integer;
  C, D: WideChar;
begin
  Result := False; IntRes := 0;
  i := 1;
  L := Length(S);
  if L = 0 then Exit;
  if (S[1] = '+') or (S[1] = '-') then
    i := 2;
  if L < i then Exit;
  if (L = i) and (S[i] = '0') then
  begin
    R.Create(0); Result := True; Exit;
  end;
  case S[i] of
  '0':
    case S[i + 1] of
    'b':
      begin
        if i + 2 > L then Exit;
        for j := i + 2 to L do
        begin
          C := S[j];
          case C of
          '0' .. '1': IntRes := IntRes shl 1 or (Ord(C) - $30);
          '_': ;
          else
            Exit;
          end;
        end;
        if S[1] <> '-' then
          R.Create(IntRes)
        else
          R.Create(-IntRes);
        Result := True;
      end;
    'x':
      begin
        if i + 2 > L then Exit;
        for j := i + 2 to L do
        begin
          C := S[j];
          case C of
          '0' .. '9': IntRes := IntRes shl 4 or (Ord(C) - $30);
          'A' .. 'F': IntRes := IntRes shl 4 or (Ord(C) - ($41 - 10));
          'a' .. 'f': IntRes := IntRes shl 4 or (Ord(C) - ($91 - 10));
          '_': ;
          else
            Exit;
          end;
        end;
        if S[1] <> '-' then
          R.Create(IntRes)
        else
          R.Create(-IntRes);
        Result := True;
      end;
    else
      begin
        for j := i + 1 to L do
        begin
          C := S[j];
          case C of
          '0' .. '7': IntRes := IntRes shl 3 or (Ord(C) - $30);
          '_': ;
          else
            Exit;
          end;
        end;
        if S[1] <> '-' then
          R.Create(IntRes)
        else
          R.Create(-IntRes);
        Result := True;
      end;
    end;
  '1' .. '9':
    begin
      for j := i to L do
      begin
        C := S[j];
        case C of
        '0' .. '9': IntRes := IntRes * 10 + (Ord(C) - $30);
        '_': ;
        ':':
          begin
            k := j;
            while k <= L do
            begin
              if k + 1 > L then Exit;
              C := S[k + 1];
              case C of
              '0' .. '5':
                begin
                  if k + 2 > L then
                  begin
                    IntRes := IntRes * 60 + (Ord(C) - $30);
                    Break;
                  end;
                  D := S[k + 2];
                  case D of
                  '0' .. '9':
                    begin
                      IntRes := IntRes * 60 + (Ord(C) - $30) * 10 + (Ord(D) - $30);
                      Inc(k, 3);
                      if k > L then Break;
                      if S[k] <> ':' then Exit;
                    end;
                  ':':
                    begin
                      IntRes := IntRes * 60 + (Ord(C) - $30);
                      Inc(k, 2);
                    end;
                  else
                    Exit;
                  end;
                end;
              '6' .. '9':
                begin
                  IntRes := IntRes * 60 + (Ord(C) - $30);
                  Inc(k, 2);
                  if k > L then Break;
                  if S[k] <> ':' then Exit;
                end;
              else
                Exit;
              end;
            end;
            Break;
          end;
        else
          Exit;
        end;
      end;
      if S[1] <> '-' then
        R.Create(IntRes)
      else
        R.Create(-IntRes);
      Result := True;
    end;
  else
    Exit;
  end;
end;

function TryYamlScalarToFloat(const S: YamlString; var R: CVariant): Boolean;
begin
  Result := False; R.Destroy;
  if MatchStringSet(S, ['.inf', '.Inf', '.INF', '+.inf', '+.Inf', '+.INF']) then
  begin
    R.Create(Math.Infinity);
    Result := True;
    Exit;
  end;
  if MatchStringSet(S, ['-.inf', '-.Inf', '-.INF']) then
  begin
    R.Create(Math.NegInfinity);
    Result := True;
    Exit;
  end;
  if MatchStringSet(S, ['.nan', '.NaN', '.NAN']) then
  begin
    R.Create(Math.NaN);
    Result := True;
    Exit;
  end;
  // TODO: float parse :(
end;

function ResolvePlainScalar(const S: YamlString): CVariant;
begin
  Result.Destroy;
  if MatchStringSet(S,
    ['y', 'Y', 'yes', 'Yes', 'YES',
     'true', 'True', 'TRUE',
     'on', 'On', 'ON']) then
    Result.Create(True)
  else if MatchStringSet(S,
    ['n', 'N', 'no', 'No', 'NO',
     'false', 'False', 'FALSE',
     'off', 'Off', 'OFF']) then
    Result.Create(False)
  else if MatchStringSet(S, ['~', 'null', 'Null', 'NULL', '']) then
    // parsed by Result.Destroy :)
  else if TryYamlScalarToInt(S, Result) then
    // parsed
  else if TryYaml then
end;

// we pass Event because there is no way to peek next event
function FromYamlInternal(const Parser: IYamlEventParser; var Event: IYamlEvent): CVariant;
var
  Key: YamlString;
begin
  Result.Destroy;
  while (Event.EventType = yamlStreamStartEvent) or
      (Event.EventType = yamlDocumentStartEvent) do
    if not Parser.Next(Event) then
      Exit;

  case Event.EventType of
  yamlDocumentEndEvent, yamlStreamEndEvent: Exit;
  yamlMappingStartEvent:
  begin
    Result.CreateM;
    while Parser.Next(Event) do
    begin
      case Event.EventType of
      yamlScalarEvent:
        begin
          Key := Event.ScalarValue;
          if not Parser.Next(Event) then
            Exit;
          Result.Put([Key], FromYamlInternal(Parser, Event));
        end;
      yamlMappingEndEvent:
        Exit;
      else
        raise EReadError.Create('Mapping parsing error: invalid sequence of events');
      end;
    end;
  end;
  yamlSequenceStartEvent:
  begin
    Result.CreateL;
    while Parser.Next(Event) do
    begin
      case Event.EventType of
      yamlSequenceEndEvent: Exit;
      else
        Result.Append(FromYamlInternal(Parser, Event));
      end;
    end;
  end;
  yamlScalarEvent:
  begin
    // TODO: recognize scalars
  end;
  end;
end;

function FromYaml(const S: UTF8String): CVariant;
var
  Parser: IYamlEventParser;
  Event: IYamlEvent;
begin
  Result.Destroy;
  Parser := YamlEventParser.Create(YamlInput.Create(S));
  if Parser.Next(Event) then
    Result := FromYamlInternal(Parser, Event);
end;

end.
