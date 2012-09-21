{$APPTYPE CONSOLE}

program Yaml.Tests.Console;

uses
  TestFrameWork,
  TextTestRunner,
  Yaml.Tests.All in 'Yaml.Tests.All.pas';

begin
  TextTestRunner.RunRegisteredTests;
end.
