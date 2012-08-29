program YamlTestsGUI;

uses
  Forms,
  TestFrameWork,
  GUITestRunner,
  YamlAllTests in 'YamlAllTests.pas';

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;
end.
