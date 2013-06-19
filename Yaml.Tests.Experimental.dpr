program Yaml.Tests.Experimental;

{$APPTYPE CONSOLE}

uses
  Yaml.Intermediate in 'Yaml.Intermediate.pas',
  Yaml.Thin in 'Yaml.Thin.pas',
  Yaml.Scalars in 'Yaml.Scalars.pas',
  Yaml In 'Yaml.pas',
  SysUtils,
  CVariants.DelphiFeatures;

var
  TestString: UTF8String =
    '{' +
    '"payment_id":"213123112312",' +
    '"status":"auth",' +
    '"params": {' +
    '"sum":"123000",' +
    '"msisdn":9035287298' +
    '}' +
    '}';

  EventParser: IYamlEventParser;
  Event: IYamlEvent;
  R: TDateTime;
begin
//  WriteLn('version: ', YamlVersion.AsString);
//  WriteLn('version2: ', YamlVersion.Major, '.', YamlVersion.Minor, '.', YamlVersion.Patch);
  WriteLn(YamlTryStrToTDateTime('2013-08-12 00:00:00 +04:00', R));
  WriteLn(YamlDateTimeToStr(R));

//  WriteLn(DumpYaml(LoadYaml(TestString)));

(*
  try
    EventParser := YamlEventParser.Create(YamlInput.Create(TestString));
    while EventParser.Next(Event) do
    begin
      case Event.EventType of
        yamlNoEvent: Write('NoEvent'#9);
        yamlStreamStartEvent: Write('StreamStart'#9);
        yamlStreamEndEvent: Write('StreamEnd'#9);
        yamlDocumentStartEvent: Write('DocumentStart'#9);
        yamlDocumentEndEvent: Write('DocumentEnd'#9);
        yamlAliasEvent: Write('Alias'#9);
        yamlScalarEvent: Write('Scalar(' + Event.ScalarTag + ', ' + Event.ScalarValue + ')'#9);
        yamlSequenceStartEvent: Write('SequenceStart'#9);
        yamlSequenceEndEvent: Write('SequenceEnd'#9);
        yamlMappingStartEvent: Write('MappingStart'#9);
        yamlMappingEndEvent: Write('MappingEnd'#9);
      end;
    end;
  except
    on E: Exception do
      WriteLn(ErrOutput, E.Message);
  end;
  *)
  ReadLn;
end.
