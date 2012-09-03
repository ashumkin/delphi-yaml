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


function LoadYaml(const S: Utf8String): CVariant;

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
var
  i, j, k, L: Integer;
  m, n: Integer;
  IntRes: Double;
  Expo: Integer;
  C, D: WideChar;
  Digits: Integer;
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

  L := Length(S);
  if L = 0 then Exit;
  i := 1;
  case S[1] of
  '+', '-': Inc(i);
  end;
  IntRes := 0.0; Digits := 0;
  if i > L then Exit;
  for j := i to L do
  begin
    C := S[j];
    case C of
    '0' .. '9': IntRes := IntRes * 10 + (Ord(C) - $30);
    '_': if j = i then Exit;
    '.':
      begin
        for k := j + 1 to L do
        begin
          C := S[k];
          case C of
          '0' .. '9': begin IntRes := IntRes * 10 + (Ord(C) - $30); Inc(Digits); end;
          '_': ;
          'e', 'E':
            begin
              // exponential
              if k + 1 > L then Exit;
              m := k + 1;
              case S[m] of
              '+', '-': Inc(m);
              end;
              Expo := 0;
              if m > L then Exit;
              for n := m to L do
              begin
                C := S[n];
                case C of
                '0' .. '9': Expo := Expo * 10 + (Ord(C) - $30);
                else
                  Exit;
                end;
              end;

              if S[k + 1] <> '-' then
                Dec(Digits, Expo)
              else
                Inc(Digits, Expo);

              if Digits < 0 then
              begin
                if S[1] <> '-' then
                  R.Create(IntRes * IntPower(0.1, Digits))
                else
                  R.Create(-IntRes * IntPower(0.1, Digits));
              end else if Digits > 0 then
              begin
                if S[1] <> '-' then
                  R.Create(IntRes * IntPower(10.0, -Digits))
                else
                  R.Create(-IntRes * IntPower(10.0, -Digits));
              end else begin
                if S[1] <> '-' then
                  R.Create(IntRes)
                else
                  R.Create(-IntRes);
              end;

              Result := True;
              Exit;
            end;
          end;
        end;

        if Digits < 0 then
        begin
          if S[1] <> '-' then
            R.Create(IntRes * IntPower(0.1, Digits))
          else
            R.Create(-IntRes * IntPower(0.1, Digits));
        end else begin
          if S[1] <> '-' then
            R.Create(IntRes)
          else
            R.Create(-IntRes);
        end;
        Result := True;
        Exit;
      end;
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
              if k + 2 > L then Exit;
              D := S[k + 2];
              case D of
              '0' .. '9':
                begin
                  IntRes := IntRes * 60 + (Ord(C) - $30) * 10 + (Ord(D) - $30);
                  Inc(k, 3);
                  if k > L then Exit;
                  case S[k] of
                  ':': ;
                  '.': Break;
                  else
                    Exit;
                  end;
                end;
              ':':
                begin
                  IntRes := IntRes * 60 + (Ord(C) - $30);
                  Inc(k, 2);
                end;
              '.':
                begin
                  IntRes := IntRes * 60 + (Ord(C) - $30);
                  Inc(k, 2);
                  Break;
                end;
              else
                Exit;
              end;
            end;
          '6' .. '9':
            begin
              IntRes := IntRes * 60 + (Ord(C) - $30);
              Inc(k, 2);
              if k > L then Exit;
              case S[k] of
              ':': ;
              '.': Break;
              else
                Exit;
              end;
            end;
          else
            Exit;
          end;
        end;

        for m := k + 1 to L do
        begin
          C := S[m];
          case C of
            '0' .. '9': begin IntRes := IntRes * 10 + (Ord(C) - $30); Inc(Digits); end;
            '_': ;
          else
            Exit;
          end;
        end;

        if Digits < 0 then
        begin
          if S[1] <> '-' then
            R.Create(IntRes * IntPower(0.1, Digits))
          else
            R.Create(-IntRes * IntPower(0.1, Digits));
        end else begin
          if S[1] <> '-' then
            R.Create(IntRes)
          else
            R.Create(-IntRes);
        end;
        Result := True;
        Exit;
      end;
    else
      Exit;
    end;
  end;
  // dot not found, failure
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
  else if TryYamlScalarToFloat(S, Result) then
    // parsed
  else // TODO: timestamp
    Result.Create(S);
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
    if Event.ScalarPlainImplicit then
      Result := ResolvePlainScalar(Event.ScalarValue)
    else
      Result.Create(Event.ScalarValue);
  end;
  end;
end;

function LoadYaml(const S: Utf8String): CVariant;
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
