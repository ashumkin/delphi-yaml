(**
 * @file Yaml.Scalars.pas
 * @brief Plain scalar resolvers
 *)

unit Yaml.Scalars;

interface

uses
  CVariants.DelphiFeatures;

{$INCLUDE 'CVariants.DelphiFeatures.inc'}

const
  yamlNullValues:  array[0 .. 4] of UnicodeString =
    ('~', 'null', 'Null', 'NULL', '');
  yamlTrueValues:  array[0 .. 10] of UnicodeString =
    ('y', 'Y', 'yes', 'Yes', 'YES', 'true',  'True',  'TRUE',  'on',  'On',  'ON');
  yamlFalseValues: array[0 .. 10] of UnicodeString =
    ('n', 'N', 'no',  'No',  'NO',  'false', 'False', 'FALSE', 'off', 'Off', 'OFF');
  yamlInfValues:   array[0 .. 5] of UnicodeString =
    ('.inf', '.Inf', '.INF', '+.inf', '+.Inf', '+.INF');
  yamlNInfValues:  array[0 .. 2] of UnicodeString = ('-.inf', '-.Inf', '-.INF');
  yamlNaNValues:   array[0 .. 2] of UnicodeString = ('.nan', '.NaN', '.NAN');

function YamlMatchStringSet(const S: UnicodeString; const SSet: array of UnicodeString): Boolean;
function YamlTryStrToNull(const S: UnicodeString): Boolean;
function YamlTryStrToBool(const S: UnicodeString; out R: Boolean): Boolean;
function YamlTryStrToInt(const S: UnicodeString; out R: Integer): Boolean;
function YamlTryStrToFloat(const S: UnicodeString; out R: Double): Boolean;
function YamlTryStrToTimeStamp(const S: UnicodeString;
  out Year, Month, Day, Hour, Min, Sec, MSec: Word; out ZoneMin: Integer): Boolean;
function YamlTryStrToTDateTime(const S: UnicodeString; out R: TDateTime): Boolean;

function YamlFloatToStr(AValue: Double): UnicodeString;
function YamlDateTimeToStr(AValue: TDateTime): UnicodeString;

implementation

uses
  SysUtils,
  Math, // Float*
  Windows, DateUtils; // TDateTime

function YamlMatchStringSet(const S: UnicodeString; const SSet: array of UnicodeString): Boolean;
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

function YamlTryStrToNull(const S: UnicodeString): Boolean;
begin
  Result := YamlMatchStringSet(S, yamlNullValues);
end;

function YamlTryStrToBool(const S: UnicodeString; out R: Boolean): Boolean;
begin
  Result := True;
  if YamlMatchStringSet(S, yamlTrueValues) then
    R := True
  else if YamlMatchStringSet(S, yamlFalseValues) then
    R := False
  else
    Result := False;
end;

function YamlTryStrToInt(const S: UnicodeString; out R: Integer): Boolean;
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
    R := 0; Result := True; Exit;
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
          R := IntRes
        else
          R := -IntRes;
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
          R := IntRes
        else
          R := -IntRes;
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
          R := IntRes
        else
          R := -IntRes;
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
        R := IntRes
      else
        R := -IntRes;
      Result := True;
    end;
  else
    Exit;
  end;
end;

function YamlTryStrToFloat(const S: UnicodeString; out R: Double): Boolean;
var
  i, j, k, L: Integer;
  m, n: Integer;
  IntRes: Double;
  Expo: Integer;
  C, D: WideChar;
  Digits: Integer;
begin
  Result := False;
  if YamlMatchStringSet(S, yamlInfValues) then
  begin
    R := Math.Infinity;
    Result := True;
    Exit;
  end;
  if YamlMatchStringSet(S, yamlNInfValues) then
  begin
    R := Math.NegInfinity;
    Result := True;
    Exit;
  end;
  if YamlMatchStringSet(S, yamlNaNValues) then
  begin
    R := Math.NaN;
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

              if Digits > 0 then
              begin
                if S[1] <> '-' then
                  R := IntRes * IntPower(0.1, Digits)
                else
                  R := -IntRes * IntPower(0.1, Digits);
              end else if Digits > 0 then
              begin
                if S[1] <> '-' then
                  R := IntRes * IntPower(10.0, -Digits)
                else
                  R := -IntRes * IntPower(10.0, -Digits);
              end else begin
                if S[1] <> '-' then
                  R := IntRes
                else
                  R := -IntRes;
              end;

              Result := True;
              Exit;
            end;
          else
            Exit;
          end;
        end;

        if Digits > 0 then
        begin
          if S[1] <> '-' then
            R := IntRes * IntPower(0.1, Digits)
          else
            R := -IntRes * IntPower(0.1, Digits);
        end else begin
          if S[1] <> '-' then
            R := IntRes
          else
            R := -IntRes;
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

        if Digits > 0 then
        begin
          if S[1] <> '-' then
            R := IntRes * IntPower(0.1, Digits)
          else
            R := -IntRes * IntPower(0.1, Digits);
        end else begin
          if S[1] <> '-' then
            R := IntRes
          else
            R := -IntRes;
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

function YamlTryStrToTimeStamp(const S: UnicodeString;
  out Year, Month, Day, Hour, Min, Sec, MSec: Word; out ZoneMin: Integer): Boolean;
var
  i, L: Integer;
  C, D, E, F: WideChar;
begin
  Result := False;
  Year := 0; Month := 0; Day := 0;
  Hour := 0; Min := 0; Sec := 0;
  MSec := 0; ZoneMin := 0;
  L := Length(S);
  if L = 0 then Exit;
  // ymd
  if L = 10 then
  repeat
    if S[5] <> '-' then Break;
    if S[8] <> '-' then Break;
    C := S[1];
    case C of
      '0' .. '9': Year := (Ord(C) - $30) * 1000;
    else
      Break;
    end;
    C := S[2];
    case C of
      '0' .. '9': Inc(Year, (Ord(C) - $30) * 100);
    else
      Break;
    end;
    C := S[3];
    case C of
      '0' .. '9': Inc(Year, (Ord(C) - $30) * 10);
    else
      Break;
    end;
    C := S[4];
    case C of
      '0' .. '9': Inc(Year, Ord(C) - $30);
    else
      Break;
    end;

    C := S[6];
    case C of
      '0' .. '9': Month := (Ord(C) - $30) * 10;
    else
      Break;
    end;
    C := S[7];
    case C of
      '0' .. '9': Inc(Month, Ord(C) - $30);
    else
      Break;
    end;

    C := S[9];
    case C of
      '0' .. '9': Day := (Ord(C) - $30) * 10;
    else
      Break;
    end;
    C := S[10];
    case C of
      '0' .. '9': Inc(Day, Ord(C) - $30);
    else
      Break;
    end;

    Result := True;
    Exit;
  until True;

  // ymdhmsfz
  if L < 14 then Exit;

  if S[5] <> '-' then Exit;

  C := S[1];
  case C of
    '0' .. '9': Year := (Ord(C) - $30) * 1000;
  else
    Exit;
  end;
  C := S[2];
  case C of
    '0' .. '9': Inc(Year, (Ord(C) - $30) * 100);
  else
    Exit;
  end;
  C := S[3];
  case C of
    '0' .. '9': Inc(Year, (Ord(C) - $30) * 10);
  else
    Exit;
  end;
  C := S[4];
  case C of
    '0' .. '9': Inc(Year, Ord(C) - $30);
  else
    Exit;
  end;

  C := S[6];
  case C of
    '0' .. '9': Month := Ord(C) - $30;
  else
    Exit;
  end;
  C := S[7];
  case C of
    '0' .. '9':
    begin
      if S[8] <> '-' then Exit;
      Month := Month * 10 + (Ord(C) - $30);
      i := 8;
    end;
    '-': i := 7;
  else
    Exit;
  end;

  C := S[i + 1];
  case C of
    '0' .. '9': Day := Ord(C) - $30;
  else
    Exit;
  end;
  C := S[i + 2];
  case C of
    '0' .. '9':
    begin
      Day := Day * 10 + (Ord(C) - $30);
      C := S[i + 3];
      case C of
        'T', 't':
        begin
          Inc(i, 4);
          C := S[i];
        end;
        #32, #9:
        begin
          Inc(i, 3);
          repeat
            Inc(i);
            if i > L then Exit;
            C := S[i];
            case C of
              #32, #9: Continue;
              '0' .. '9': Break;
            else
              Exit;
            end;
          until False;
        end;
      else
        Exit;
      end;
    end;
    'T', 't':
    begin
      Inc(i, 3);
      C := S[i];
    end;
    #32, #9:
    begin
      Inc(i, 2);
      repeat
        Inc(i);
        if i > L then Exit;
        C := S[i];
        case C of
          #32, #9: Continue;
          '0' .. '9': Break;
        else
          Exit;
        end;
      until False;
    end;
  else
    Exit;
  end;

  case C of
    '0' .. '9': Hour := Ord(C) - $30;
  else
    Exit;
  end;
  if i + 2 > L then Exit;
  C := S[i + 1];
  case C of
    '0' .. '9':
    begin
      if S[i + 2] <> ':' then Exit;
      Hour := Hour * 10 + (Ord(C) - $30);
      Inc(i, 3);
    end;
    ':': Inc(i, 2);
  else
    Exit;
  end;

  if i + 2 > L then Exit;
  C := S[i];
  case C of
    '0' .. '9': Min := Ord(C) - $30;
  else
    Exit;
  end;
  C := S[i + 1];
  case C of
    '0' .. '9':
    begin
      if S[i + 2] <> ':' then Exit;
      Min := Min * 10 + (Ord(C) - $30);
      Inc(i, 3);
    end;
    ':': Inc(i, 2);
  else
    Exit;
  end;

  if i > L then Exit;
  C := S[i];
  case C of
    '0' .. '9': Sec := Ord(C) - $30;
  else
    Exit;
  end;
  if i + 1 <= L then
  begin
    C := S[i + 1];
    case C of
      '0' .. '9':
      begin
        Inc(i, 2);
        Sec := Sec * 10 + (Ord(C) - $30);
      end;
      '.', #32, #9, 'Z', '+', '-': Inc(i, 1);
    else
      Exit;
    end;
  end else Inc(i, 1);

  if (i <= L) and (S[i] = '.') then
  begin
    if i + 1 <= L then
    begin
      C := S[i + 1];
      case C of
        '0' .. '9':
        begin
          if i + 2 <= L then
          begin
            D := S[i + 2];
            case D of
              '0' .. '9':
              begin
                if i + 3 <= L then
                begin
                  E := S[i + 3];
                  case E of
                    '0' .. '9':
                    begin
                      if i + 4 <= L then
                      begin
                        F := S[i + 4];
                        case F of
                          '0' .. '4':
                          begin
                            MSec := (Ord(C) - $30) * 100 + (Ord(D) - $30) * 10 +
                              (Ord(E) - $30);
                            Inc(i, 5);
                          end;
                          '5' .. '9':
                          begin
                            MSec := (Ord(C) - $30) * 100 + (Ord(D) - $30) * 10 +
                              (Ord(E) - $30) + 1;
                            Inc(i, 5);
                          end;
                          #32, #9, 'Z', '+', '-':
                          begin
                            MSec := (Ord(C) - $30) * 100 + (Ord(D) - $30) * 10 +
                              (Ord(E) - $30);
                            Inc(i, 4);
                          end;
                        else
                          Exit;
                        end;
                      end else
                      begin
                        MSec := (Ord(C) - $30) * 100 + (Ord(D) - $30) * 10 +
                          (Ord(E) - $30);
                        Inc(i, 4);
                      end;
                    end;
                    #32, #9, 'Z', '+', '-':
                    begin
                      MSec := (Ord(C) - $30) * 100 + (Ord(D) - $30) * 10;
                      Inc(i, 3);
                    end;
                  else
                    Exit;
                  end;
                end else
                begin
                  MSec := (Ord(C) - $30) * 100 + (Ord(D) - $30) * 10;
                  Inc(i, 3);
                end;
              end;
              #32, #9, 'Z', '+', '-':
              begin
                MSec := (Ord(C) - $30) * 100;
                Inc(i, 2);
              end;
            else
              Exit;
            end;
          end else
          begin
            MSec := (Ord(C) - $30) * 100;
            Inc(i, 2);
          end;
        end;
        #32, #9, 'Z', '+', '-': Inc(i, 1);
      else
        Exit;
      end;
    end else Inc(i, 1);
  end;

  while i <= L do
    case S[i] of
      #32, #9: Inc(i);
      'Z', '+', '-': Break;
    else
      Exit;
    end;

  if i <= L then
  begin
    F := S[i];
    case F of
      'Z': if i <> L then Exit;
      '+', '-':
      begin
        if i + 1 <= L then
        begin
          C := S[i + 1];
          case C of
            '0' .. '9':
            begin
              if i + 2 <= L then
              begin
                D := S[i + 2];
                case D of
                  '0' .. '9':
                  begin
                    ZoneMin := (Ord(C) - $30) * 600 + (Ord(D) - $30) * 60;
                    Inc(i, 3);
                  end;
                  ':':
                  begin
                    ZoneMin := (Ord(C) - $30) * 60;
                    Inc(i, 2);
                  end;
                else
                  Exit;
                end;
              end else
              begin
                ZoneMin := (Ord(C) - $30) * 60;
                Inc(i, 2);
              end;
            end;
          else
            Exit;
          end;
        end else
          Exit;

        if i <= L then
        begin
          if S[i] <> ':' then Exit;

          if i + 1 <= L then
          begin
            C := S[i + 1];
            case C of
              '0' .. '9':
              begin
                if i + 2 <= L then
                begin
                  if i + 2 <> L then Exit;
                  D := S[i + 2];
                  case D of
                    '0' .. '9':
                    begin
                      ZoneMin := ZoneMin + (Ord(C) - $30) * 10 + (Ord(D) - $30);
                    end;
                  else
                    Exit;
                  end;
                end else
                begin
                  ZoneMin := ZoneMin + (Ord(C) - $30);
                end;
              end;
            else
              Exit;
            end;
          end else
            Exit;
        end;

        if F = '-' then
          ZoneMin := -ZoneMin;
      end;
    else
      Exit;
    end;
  end;

  Result := True;
  Exit;
end;

function YamlTryStrToTDateTime(const S: UnicodeString; out R: TDateTime): Boolean;
var
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
  ZoneMin: Integer;
  GlobalTime, LocalTime: TSystemTime;
begin
  Result := False;
  if YamlTryStrToTimeStamp(S, Year, Month, Day, Hour, Min, Sec, MSec, ZoneMin) then
  begin
    GlobalTime.wYear := Year; GlobalTime.wMonth := Month; GlobalTime.wDay := Day;
    GlobalTime.wHour := Hour; GlobalTime.wMinute := Min; GlobalTime.wSecond := Sec;
    GlobalTime.wMilliseconds := MSec;
    if not SystemTimeToTzSpecificLocalTime(nil, GlobalTime, LocalTime) then
      RaiseLastOSError;

    if ZoneMin <> 0 then
      R := IncMinute(SystemTimeToDateTime(LocalTime), -ZoneMin)
    else
      R := SystemTimeToDateTime(LocalTime);

    Result := True;
  end;
end;

function YamlFloatToStr(AValue: Double): UnicodeString;
var
  fs: TFormatSettings;
  epos: Integer;
begin
  if IsNan(AValue) then
    Result := '.nan'
  else if IsInfinite(AValue) then
  begin
    if Sign(AValue) > 0 then
      Result := '.inf'
    else
      Result := '-.inf';
  end else
  begin
    fs.DecimalSeparator := '.';
    Result := FloatToStr(AValue, fs);
    epos := Pos('E', Result);
    if Pos('.', Result) = 0 then
    begin
      if epos = 0 then
        Result := Result + '.0'
      else
      begin
        {$WARN UNSAFE_CODE OFF}
        Result[epos] := 'e';
        {$WARN UNSAFE_CODE ON}
        case Result[epos + 1] of '+', '-': ; else Insert('+', Result, epos + 1); end;
        Insert('.0', Result, epos);
      end;
    end else begin
      if epos <> 0 then
      begin
        {$WARN UNSAFE_CODE OFF}
        Result[epos] := 'e';
        {$WARN UNSAFE_CODE ON}
        case Result[epos + 1] of '+', '-': ; else Insert('+', Result, epos + 1); end;
      end;
    end;
  end;
end;

function YamlDateTimeToStr(AValue: TDateTime): UnicodeString;
var
  tzi: TTimeZoneInformation;
  Year, Month, Day, Hour, Minute, Second, MilliSecond: Word;
  S: string;
begin
  if GetTimeZoneInformation(tzi) = $FFFFFFFF then // TIME_ZONE_ID_INVALID
    RaiseLastOSError;

  DecodeDateTime(AValue, Year, Month, Day, Hour, Minute, Second, MilliSecond);
  S := IntToStr(Year);
  S := StringOfChar('0', 4 - Length(S)) + S;
  Result := S;
  S := IntToStr(Month);
  S := StringOfChar('0', 2 - Length(S)) + S;
  Result := Result + '-' + S;
  S := IntToStr(Day);
  S := StringOfChar('0', 2 - Length(S)) + S;
  Result := Result + '-' + S;
  S := IntToStr(Hour);
  S := StringOfChar('0', 2 - Length(S)) + S;
  Result := Result + 'T' + S;
  S := IntToStr(Minute);
  S := StringOfChar('0', 2 - Length(S)) + S;
  Result := Result + ':' + S;
  S := IntToStr(Second);
  S := StringOfChar('0', 2 - Length(S)) + S;
  Result := Result + ':' + S;
  S := IntToStr(MilliSecond);
  S := '.' + StringOfChar('0', 3 - Length(S)) + S;
  if S = '.000' then
    S := ''
  else if Copy(S, 3, 2) = '00' then
    Delete(S, 3, 2)
  else if Copy(S, 4, 1) = '0' then
    Delete(S, 4, 1);
  Result := Result + S;

  if tzi.Bias = 0 then
    Result := Result + 'Z'
  else if tzi.Bias < 0 then
  begin
    S := IntToStr((-tzi.Bias) div 60);
    S := StringOfChar('0', 2 - Length(S)) + S;
    Result := Result + ' +' + S;
    S := IntToStr((-tzi.Bias) mod 60);
    S := StringOfChar('0', 2 - Length(S)) + S;
    Result := Result + ':' + S;
  end else
  begin
    S := IntToStr(tzi.Bias div 60);
    S := StringOfChar('0', 2 - Length(S)) + S;
    Result := Result + ' -' + S;
    S := IntToStr(tzi.Bias mod 60);
    S := StringOfChar('0', 2 - Length(S)) + S;
    Result := Result + ':' + S;
  end;
end;

end.
