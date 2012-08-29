unit YamlTestsSimple;

interface

uses
  TestFramework,
  YamlDelphiFeatures, YamlIntermediate;

implementation

type
  TYamlParseTests = class(TTestCase)
  protected
    FString: UTF8String;
    FEventParser: IYamlEventParser;
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
  FString := 'testdict:'#13#10 +
    '  - 2'#13#10 +
    '  -'#13#10 +
    '  - ["4", true]'#13#10 +
    '"another key": abc'#13#10;
  FEventParser := YamlEventParser.Create(YamlInput.Create(FString));
end;

procedure TYamlParseTests.TestParse;
var
  Event: IYamlEvent;
begin
  while FEventParser.Next(Event) do
  begin
    case Event.EventType of
      yamlNoEvent: Write('NoEvent'#9);
      yamlStreamStartEvent: Write('StreamStart'#9);
      yamlStreamEndEvent: Write('StreamEnd'#9);
      yamlDocumentStartEvent: Write('DocumentStart'#9);
      yamlDocumentEndEvent: Write('DocumentEnd'#9);
      yamlAliasEvent: Write('Alias'#9);
      yamlScalarEvent: Write('Scalar(' + Event.ScalarValue + ')'#9);
      yamlSequenceStartEvent: Write('SequenceStart'#9);
      yamlSequenceEndEvent: Write('SequenceEnd'#9);
      yamlMappingStartEvent: Write('MappingStart'#9);
      yamlMappingEndEvent: Write('MappingEnd'#9);
    end;
  end;
end;

initialization
  RegisterTest(
    TTestSuite.Create('Yaml simple tests',
    [TYamlParseTests.Suite]));
end.