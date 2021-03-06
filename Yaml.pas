(**
 * @file Yaml.pas
 * @brief Thick binding to libyaml (import/export to CVariant)
 *)

unit Yaml;

interface

uses
  SysUtils, Classes, Types, Yaml.Intermediate, CVariants.DelphiFeatures,
  CVariants;

{$INCLUDE 'CVariants.DelphiFeatures.inc'}

{$IFNDEF DELPHI_HAS_RECORDS}
{$WARN UNSAFE_TYPE OFF} // CVariant
{$ENDIF}

function LoadYamlUtf8(const S: Utf8String): CVariant;
function DumpYamlUtf8(const Obj: CVariant): UTF8String;
function DumpJsonUtf8(const Obj: CVariant; Indent: Integer = 0): UTF8String;

function LoadYaml(const S: UnicodeString): CVariant;
function DumpYaml(const Obj: CVariant): UnicodeString;
function DumpJson(const Obj: CVariant; Indent: Integer = 0): UnicodeString;

implementation

uses
  StrUtils, // IfThen
  Variants, // Destroy, CreateDT inline
  Yaml.Scalars;

function ResolvePlainScalar(const S: UnicodeString): CVariant;
var
  BoolTmp: Boolean;
  IntTmp: Integer;
  FloatTmp: Double;
  DateTimeTmp: TDateTime;
begin
  Result.Destroy;
  if YamlTryStrToNull(S) then
    // parsed by Result.Destroy :)
  else if YamlTryStrToBool(S, BoolTmp) then
    Result.Create(BoolTmp)
  else if YamlTryStrToInt(S, IntTmp) then
    Result.Create(IntTmp)
  else if YamlTryStrToFloat(S, FloatTmp) then
    Result.Create(FloatTmp)
  else if YamlTryStrToTDateTime(S, DateTimeTmp) then
    Result.CreateDT(DateTimeTmp)
  else // TODO: timestamp
    Result.Create(S);
end;

// we pass Event because there is no way to peek next event
function FromYamlInternal(const Parser: IYamlEventParser; var Event: IYamlEvent): CVariant;
var
  Key: UnicodeString;
  BoolTmp: Boolean;
  IntTmp: Integer;
  FloatTmp: Double;
  DateTimeTmp: TDateTime;
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
    Key := Event.ScalarTag;
    if Key = '' then
    begin
      if Event.ScalarPlainImplicit then
        Result := ResolvePlainScalar(Event.ScalarValue)
      else
        Result.Create(Event.ScalarValue);
    end
    else if Key = yamlNullTag then
    begin
      if YamlTryStrToNull(Event.ScalarValue) then
      // parsed by Result.Destroy
      else
        raise EYamlConstructorError.Create('', nil, 'Invalid !!null value: ' + Event.ScalarValue, Event.StartMark);
    end
    else if Key = yamlBoolTag then
    begin
      if YamlTryStrToBool(Event.ScalarValue, BoolTmp) then
        Result.Create(BoolTmp)
      else
        raise EYamlConstructorError.Create('', nil, 'Invalid !!bool value: ' + Event.ScalarValue, Event.StartMark);
    end
    else if Key = yamlIntTag then
    begin
      if YamlTryStrToInt(Event.ScalarValue, IntTmp) then
        Result.Create(IntTmp)
      else
        raise EYamlConstructorError.Create('', nil, 'Invalid !!int value: ' + Event.ScalarValue, Event.StartMark);
    end
    else if Key = yamlFloatTag then
    begin
      if YamlTryStrToFloat(Event.ScalarValue, FloatTmp) then
        Result.Create(FloatTmp)
      else
        raise EYamlConstructorError.Create('', nil, 'Invalid !!float value: ' + Event.ScalarValue, Event.StartMark);
    end
    else if Key = yamlTimestampTag then
    begin
      if YamlTryStrToTDateTime(Event.ScalarValue, DateTimeTmp) then
        Result.CreateDT(DateTimeTmp)
      else
        raise EYamlConstructorError.Create('', nil, 'Invalid !!timestamp value: ' + Event.ScalarValue, Event.StartMark);
    end
    else if Key = yamlStrTag then
    begin
      Result.Create(Event.ScalarValue);
    end
    else
      raise EYamlConstructorError.Create('', nil, 'Tag is not supported: ' + Key, Event.StartMark);
  end;
  yamlAliasEvent:
    raise EYamlConstructorError.Create('', nil, 'Aliases are not supported', Event.StartMark);
  end;
end;

procedure DumpYamlInternal(const Emitter: IYamlEventEmitter; const Obj: CVariant);
var
  Event: IYamlEvent;
  LI: CListIterator;
  MI: CMapIterator;
begin
  case Obj.VType of
    vtEmpty, vtNull:
    begin
      Event := YamlEventScalar.Create('', '', 'null', True, False, yamlPlainScalarStyle);
      Emitter.Emit(Event);
    end;
    vtBoolean:
    begin
      Event := YamlEventScalar.Create('', '', IfThen(Obj.ToBool, 'true', 'false'), True, False, yamlPlainScalarStyle);
      Emitter.Emit(Event);
    end;
    vtInteger:
    begin
      Event := YamlEventScalar.Create('', '', IntToStr(Obj.ToInt), True, False, yamlPlainScalarStyle);
      Emitter.Emit(Event);
    end;
    vtExtended:
    begin
      Event := YamlEventScalar.Create('', '', YamlFloatToStr(Obj.ToFloat), True, False, yamlPlainScalarStyle);
      Emitter.Emit(Event);
    end;
    vtDateTime:
    begin
      Event := YamlEventScalar.Create('', '', YamlDateTimeToStr(Obj.ToDateTime), True, False, yamlPlainScalarStyle);
      Emitter.Emit(Event);
    end;
    vtString:
    begin
      Event := YamlEventScalar.Create('', '', Obj.ToString, False, True, yamlDoubleQuotedScalarStyle);
      Emitter.Emit(Event);
    end;
    vtList:
    begin
      Event := YamlEventSequenceStart.Create('', '', True, yamlBlockSequenceStyle);
      Emitter.Emit(Event);
      LI.Create(Obj);
      while LI.Next do
        DumpYamlInternal(Emitter, LI.Value);
      LI.Destroy;
      Event := YamlEventSequenceEnd.Create;
      Emitter.Emit(Event);
    end;
    vtMap:
    begin
      Event := YamlEventMappingStart.Create('', '', True, yamlBlockMappingStyle);
      Emitter.Emit(Event);
      MI.Create(Obj);
      while MI.Next do
      begin
        Event := YamlEventScalar.Create('', '', MI.Key, True, True, yamlAnyScalarStyle);
        Emitter.Emit(Event);
        DumpYamlInternal(Emitter, MI.Value);
      end;
      MI.Destroy;
      Event := YamlEventMappingEnd.Create;
      Emitter.Emit(Event);
    end;
  end;
end;

procedure DumpJsonInternal(const Emitter: IYamlEventEmitter; const Obj: CVariant; Indent: Integer; CurrentIndent: Integer = 0);
var
  Event: IYamlEvent;
  LI: CListIterator;
  MI: CMapIterator;
begin
  if (Indent > 0) and ((Obj.VType = vtMap) or (Obj.VType = vtList)) then
  begin
    Emitter.PutWhitespace(CurrentIndent);
  end;

  case Obj.VType of
    vtEmpty, vtNull:
    begin
      Event := YamlEventScalar.Create('', '', 'null', True, False, yamlPlainScalarStyle);
      Emitter.Emit(Event);
    end;
    vtBoolean:
    begin
      Event := YamlEventScalar.Create('', '', IfThen(Obj.ToBool, 'true', 'false'), True, False, yamlPlainScalarStyle);
      Emitter.Emit(Event);
    end;
    vtInteger:
    begin
      Event := YamlEventScalar.Create('', '', IntToStr(Obj.ToInt), True, False, yamlPlainScalarStyle);
      Emitter.Emit(Event);
    end;
    vtExtended:
    begin
      Event := YamlEventScalar.Create('', '', YamlFloatToStr(Obj.ToFloat), True, False, yamlPlainScalarStyle);
      Emitter.Emit(Event);
    end;
    vtDateTime:
    begin
      Event := YamlEventScalar.Create('', '', YamlDateTimeToStr(Obj.ToDateTime), True, False, yamlDoubleQuotedScalarStyle);
      Emitter.Emit(Event);
    end;
    vtString:
    begin
      Event := YamlEventScalar.Create('', '', Obj.ToString, False, True, yamlDoubleQuotedScalarStyle);
      Emitter.Emit(Event);
    end;
    vtList:
    begin
      Event := YamlEventSequenceStart.Create('', '', True, yamlFlowSequenceStyle);
      Emitter.Emit(Event);
      LI.Create(Obj);
      while LI.Next do
      begin
        if (Indent > 0) and ((LI.Value.VType = vtMap) or (LI.Value.VType = vtList)) then
        begin
          Emitter.PutBreak;
        end;
        DumpJsonInternal(Emitter, LI.Value, Indent, CurrentIndent + Indent);
      end;
      LI.Destroy;
      if Indent > 0 then
      begin
        Emitter.PutBreak;
        Emitter.PutWhitespace(CurrentIndent);
      end;
      Event := YamlEventSequenceEnd.Create;
      Emitter.Emit(Event);
    end;
    vtMap:
    begin
      Event := YamlEventMappingStart.Create('', '', True, yamlFlowMappingStyle);
      Emitter.Emit(Event);
      MI.Create(Obj);
      while MI.Next do
      begin
        if (Indent > 0) and ((LI.Value.VType = vtMap) or (LI.Value.VType = vtList)) then
        begin
          Emitter.PutBreak;
        end;
        Event := YamlEventScalar.Create('', '', MI.Key, True, True, yamlDoubleQuotedScalarStyle);
        Emitter.Emit(Event);
        DumpJsonInternal(Emitter, MI.Value, Indent, CurrentIndent + Indent);
      end;
      MI.Destroy;
      if Indent > 0 then
      begin
        Emitter.PutBreak;
        Emitter.PutWhitespace(CurrentIndent);
      end;
      Event := YamlEventMappingEnd.Create;
      Emitter.Emit(Event);
    end;
  end;
end;

function DumpYamlUtf8(const Obj: CVariant): UTF8String;
var
  MS: TMemoryStream;
  Emitter: IYamlEventEmitter;
  Event: IYamlEvent;
begin
  MS := TMemoryStream.Create;
  try
    Emitter := YamlEventEmitter.Create(YamlOutput.Create(MS, yamlUtf8Encoding));
    Event := YamlEventStreamStart.Create(yamlUtf8Encoding);
    Emitter.Emit(Event);
    Event := YamlEventDocumentStart.Create(nil, [], True);
    Emitter.Emit(Event);

    DumpYamlInternal(Emitter, Obj);

    // Event := YamlEventDocumentEnd.Create(True);  // don't write end of line
    // Emitter.Emit(Event);
    // Event := YamlEventStreamEnd.Create;          // don't write '...'
    // Emitter.Emit(Event);
    Emitter.Flush;

    if MS.Size = 0 then
      Result := ''
    else
      SetString(Result, PAnsiChar(MS.Memory), MS.Size);
  finally
    FreeAndNil(MS);
  end;
end;

function DumpJsonUtf8(const Obj: CVariant; Indent: Integer = 0): UTF8String;
var
  MS: TMemoryStream;
  Emitter: IYamlEventEmitter;
  Event: IYamlEvent;
begin
  MS := TMemoryStream.Create;
  try
    Emitter := YamlEventEmitter.Create(YamlOutput.Create(MS, yamlUtf8Encoding));
    Event := YamlEventStreamStart.Create(yamlUtf8Encoding);
    Emitter.Emit(Event);
    Event := YamlEventDocumentStart.Create(nil, [], True);
    Emitter.Emit(Event);

    DumpJsonInternal(Emitter, Obj, Indent);

    // Event := YamlEventDocumentEnd.Create(True);  // don't write end of line
    // Emitter.Emit(Event);
    // Event := YamlEventStreamEnd.Create;          // don't write '...'
    // Emitter.Emit(Event);
    Emitter.Flush;

    if MS.Size = 0 then
      Result := ''
    else
      SetString(Result, PAnsiChar(MS.Memory), MS.Size);
  finally
    FreeAndNil(MS);
  end;
end;

function LoadYamlUtf8(const S: Utf8String): CVariant;
var
  Parser: IYamlEventParser;
  Event: IYamlEvent;
begin
  Result.Destroy;
  Parser := YamlEventParser.Create(YamlInput.Create(S));
  if Parser.Next(Event) then
    Result := FromYamlInternal(Parser, Event);
end;

function LoadYaml(const S: UnicodeString): CVariant;
var
  Parser: IYamlEventParser;
  Event: IYamlEvent;
begin
  Result.Destroy;
  Parser := YamlEventParser.Create(YamlInput.Create(S));
  if Parser.Next(Event) then
    Result := FromYamlInternal(Parser, Event);
end;

function DumpYaml(const Obj: CVariant): UnicodeString;
var
  MS: TMemoryStream;
  Emitter: IYamlEventEmitter;
  Event: IYamlEvent;
begin
  MS := TMemoryStream.Create;
  try
    Emitter := YamlEventEmitter.Create(YamlOutput.Create(MS, yamlUtf16leEncoding));
    Event := YamlEventStreamStart.Create(yamlUtf16leEncoding);
    Emitter.Emit(Event);
    Event := YamlEventDocumentStart.Create(nil, [], True);
    Emitter.Emit(Event);

    DumpYamlInternal(Emitter, Obj);

    // Event := YamlEventDocumentEnd.Create(True);  // don't write end of line
    // Emitter.Emit(Event);
    // Event := YamlEventStreamEnd.Create;          // don't write '...'
    // Emitter.Emit(Event);
    Emitter.Flush;

    if MS.Size = 0 then
      Result := ''
    else
      SetString(Result, PWideChar(MS.Memory) + 1, MS.Size div 2 - 1); // strip BOM
  finally
    FreeAndNil(MS);
  end;
end;

function DumpJson(const Obj: CVariant; Indent: Integer = 0): UnicodeString;
var
  MS: TMemoryStream;
  Emitter: IYamlEventEmitter;
  Event: IYamlEvent;
begin
  MS := TMemoryStream.Create;
  try
    Emitter := YamlEventEmitter.Create(YamlOutput.Create(MS, yamlUtf16leEncoding));
    Event := YamlEventStreamStart.Create(yamlUtf16leEncoding);
    Emitter.Emit(Event);
    Event := YamlEventDocumentStart.Create(nil, [], True);
    Emitter.Emit(Event);

    DumpJsonInternal(Emitter, Obj, Indent);

    // Event := YamlEventDocumentEnd.Create(True);  // don't write end of line
    // Emitter.Emit(Event);
    // Event := YamlEventStreamEnd.Create;          // don't write '...'
    // Emitter.Emit(Event);
    Emitter.Flush;

    if MS.Size = 0 then
      Result := ''
    else
      SetString(Result, PWideChar(MS.Memory) + 1, MS.Size div 2 - 1); // strip BOM
  finally
    FreeAndNil(MS);
  end;
end;

end.
