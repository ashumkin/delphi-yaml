program YamlTestsGUI;

uses
  Forms,
  TestFrameWork,
  GUITestRunner,
  Yaml.Tests.All in 'Yaml.Tests.All.pas';

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;
end.
