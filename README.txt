Delphi-YAML - a Delphi bindings for libyaml .

Delphi-YAML actually consists of several layers:
1. Thin bindings (YamlThin): C-level API
2. Intermediate bindings (YamlIntermediate):
  using interfaces and exceptions, but still dealing
  with events and processes (or tokens)
  IYamlDocument is pretty low-level. There is no lookups.
  There is no plain scalar resolver here.
3. Thick (Yaml): Load from and dump to CVariants.
  LoadYaml and DumpYaml is everything it has at the 
  moment.
4. Rtti (not implemented): load from and dump to 
  Delphi objects and interfaces.


Dependencies:
- Borland C++ 5.5
- dUnit: http://dunit.sf.net/
- CVariants v0.1.1: https://bitbucket.org/OCTAGRAM/delphi-cvariants

Use compile.cmd to recompile C part of libyaml.

You can download Borland C++ 5.5 free command line tools here: 
https://downloads.embarcadero.com/free/c_builder

BitBucket project page: https://bitbucket.org/OCTAGRAM/delphi-yaml


The LibYAML library is written by Kirill Simonov.

LibYAML is released under the MIT license. (LICENSE.C.txt)

The Delphi-YAML library is written by Ivan Levashew.

LibYAML is released under the MIT license. (LICENSE.Delphi.txt)
