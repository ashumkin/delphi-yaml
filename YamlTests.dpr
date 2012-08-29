{$APPTYPE CONSOLE}

program YamlTests;

uses
  TestFrameWork,
  TextTestRunner,
  YamlAllTests in 'YamlAllTests.pas';

begin
  TextTestRunner.RunRegisteredTests;
end.
