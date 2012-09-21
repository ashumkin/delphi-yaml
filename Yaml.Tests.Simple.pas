unit Yaml.Tests.Simple;

interface

uses
  TestFramework,
  CVariants.DelphiFeatures, Yaml.Intermediate;

implementation

type
  TYamlTests = class(TTestCase)
  protected
    FEventParser: IYamlEventParser;
    FEvent: IYamlEvent;
    class function EventTypeToString(AEventType: TYamlEventType): string;
    procedure CheckEvent(AEventType: TYamlEventType); overload;
    procedure CheckEvent(const AScalarValue: YamlString); overload;
  end;

  TYamlParseTests = class(TYamlTests)
  protected
    FString: UTF8String;
    procedure SetUp; override;
  published
    procedure TestParse;
  end;

//  WriteLn('version: ', YamlVersion.AsString);
//  WriteLn('version2: ', YamlVersion.Major, '.', YamlVersion.Minor, '.', YamlVersion.Patch);


{ TYamlParseTests }

procedure TYamlParseTests.SetUp;
begin
  inherited;
  FString :=
    'testdict:'#13#10 +
    '  - 2'#13#10 +
    '  -'#13#10 +
    '  - ["4", true]'#13#10 +
    '"another key": abc'#13#10;
  FEventParser := YamlEventParser.Create(YamlInput.Create(FString));
end;

procedure TYamlParseTests.TestParse;
begin
  CheckEvent(yamlStreamStartEvent);
    CheckEvent(yamlDocumentStartEvent);
      CheckEvent(yamlMappingStartEvent);
        CheckEvent('testdict');
          CheckEvent(yamlSequenceStartEvent);
            CheckEvent('2');
            CheckEvent('');
            CheckEvent(yamlSequenceStartEvent);
              CheckEvent('4');
              CheckEvent('true');
            CheckEvent(yamlSequenceEndEvent);
          CheckEvent(yamlSequenceEndEvent);
        CheckEvent('another key');
          CheckEvent('abc');
      CheckEvent(yamlMappingEndEvent);
    CheckEvent(yamlDocumentEndEvent);
  CheckEvent(yamlStreamEndEvent);
  CheckFalse(FEventParser.Next(FEvent));
end;

{ TYamlTests }

procedure TYamlTests.CheckEvent(AEventType: TYamlEventType);
begin
  CheckTrue(FEventParser.Next(FEvent), 'YamlParser.Next');
  CheckEquals(EventTypeToString(AEventType),
    EventTypeToString(FEvent.EventType), 'Event.EventType');
end;

procedure TYamlTests.CheckEvent(const AScalarValue: YamlString);
begin
  CheckTrue(FEventParser.Next(FEvent), 'YamlParser.Next');
  CheckEquals(EventTypeToString(yamlScalarEvent),
    EventTypeToString(FEvent.EventType), 'Event.EventType');
  CheckEquals(AScalarValue, FEvent.ScalarValue, 'Event.ScalarValue');
end;

class function TYamlTests.EventTypeToString(
  AEventType: TYamlEventType): string;
begin
  case AEventType of
    yamlNoEvent: Result := 'NoEvent';
    yamlStreamStartEvent: Result := 'StreamStart';
    yamlStreamEndEvent: Result := 'StreamEnd';
    yamlDocumentStartEvent: Result := 'DocumentStart';
    yamlDocumentEndEvent: Result := 'DocumentEnd';
    yamlAliasEvent: Result := 'Alias';
    yamlScalarEvent: Result := 'Scalar';
    yamlSequenceStartEvent: Result := 'SequenceStart';
    yamlSequenceEndEvent: Result := 'SequenceEnd';
    yamlMappingStartEvent: Result := 'MappingStart';
    yamlMappingEndEvent: Result := 'MappingEnd';
  end;
end;

initialization
  RegisterTest(
    TTestSuite.Create('Yaml simple tests',
    [TYamlParseTests.Suite]));
end.