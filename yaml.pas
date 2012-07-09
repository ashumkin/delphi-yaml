(**
 * @file yaml.h
 * @brief Public interface for libyaml.
 *)


unit YAML;

interface

uses
  SysUtils, Classes, Types, YamlThin;


type
  (**
   * @defgroup version Version Information
   * @{
   *)

  IYamlVersion = interface
  ['{0B1F5CC2-3E4C-4D4C-922B-6E3F1EB871D8}']
    function GetAsString: string;
    function GetMajor: Integer;
    function GetMinor: Integer;
    function GetPatch: Integer;

  (**
   * Get the library version as a string.
   *
   * @returns The function returns the pointer to a static string of the form
   * @c "X.Y.Z", where @c X is the major version number, @c Y is a minor version
   * number, and @c Z is the patch version number.
   *)

    property AsString: string read GetAsString;

  (**
   * Get the library version numbers.
   *
   * @param[out]      major   Major version number.
   * @param[out]      minor   Minor version number.
   * @param[out]      patch   Patch version number.
   *)

    property Major: Integer read GetMajor;
    property Minor: Integer read GetMinor;
    property Patch: Integer read GetPatch;
  end;
function YamlVersion: IYamlVersion;
type

  (** @} *)

  (**
   * @defgroup basic Basic Types
   * @{
   *)

  (** The character type (UTF-8 octet). *)
  UString = WideString; // change to UnicodeString on XE2

  (** The version directive data. *)
  IYamlVersionDirective = interface
  ['{90DD4239-7F44-4B5A-B1D2-F5DCE8C1D41A}']
    function GetMajor: Integer;
    function GetMinor: Integer;
    (** The major version number. *)
    property Major: Integer read GetMajor;
    (** The minor version number. *)
    property Minor: Integer read GetMinor;
  end;
  TIYamlTagDirectiveDynArray = array of IYamlVersionDirective;

  (** The tag directive data. *)
  IYamlTagDirective = interface
  ['{C97DAEAC-9F62-4001-A23F-EF27ED5BF48D}']
    function GetHandle: UString;
    function GetPrefix: UString;
    (** The tag handle. *)
    property Handle: UString read GetHandle;
    (** The tag prefix. *)
    property Prefix: UString read GetPrefix;
  end;

  (** The stream encoding. *)
  TYamlEncoding = YamlThin.TYamlEncoding;

  (** Line break types. *)

  TYamlBreak = YamlThin.TYamlBreak;

  (** Many bad things could happen with the parser and emitter. *)
  EYamlError = class(Exception);
  (** No error is produced. *)
  // no error, no exception

  (** Cannot allocate or reallocate a block of memory. *)
  EYamlMemoryError = class(EYamlError);

  (** Cannot read or decode the input stream. *)
  EYamlReaderError = class(EYamlError);
  (** Cannot scan the input stream. *)
  EYamlScannerError = class(EYamlError);
  (** Cannot parse the input stream. *)
  EYamlParserError = class(EYamlError);
  (** Cannot compose a YAML document. *)
  EYamlComposerError = class(EYamlError);

  (** Cannot write to the output stream. *)
  EYamlWriterError = class(EYamlError);
  (** Cannot emit a YAML stream. *)
  EYamlEmitterError = class(EYamlError);

  (** The pointer position. *)
  IYamlMark = interface
  ['{DB5BD8F3-5703-44D6-9237-D014E0748459}']
    function GetIndex: Integer;
    function GetLine: Integer;
    function GetColumn: Integer;
    (** The position index. *)
    property Index: Integer read GetIndex;

    (** The position line. *)
    property Line: Integer read GetLine;

    (** The position column. *)
    property Column: Integer read GetColumn;
  end;

  (** @} *)

  (**
   * @defgroup styles Node Styles
   * @{
   *)

  (** Scalar styles. *)
  TYamlScalarStyle = YamlThin.TYamlScalarStyle;

  (** Sequence styles. *)
  TYamlSequenceStyle = YamlThin.TYamlSequenceStyle;

  (** Mapping styles. *)
  TYamlMappingStyle = YamlThin.TYamlMappingStyle;

  (** @} *)

  (**
   * @defgroup tokens Tokens
   * @{
   *)

  (** Token types. *)
  TYamlTokenType = YamlThin.TYamlTokenType;

  (** The token structure. *)
  IYamlToken = interface
  ['{AB5E049D-123D-45EB-BFB3-D7B5424AECB4}']
    function GetType_: TYamlTokenType;
    function GetStreamStartEncoding: TYamlEncoding;
    function GetAliasValue: UString;
    function GetAnchorValue: UString;
    function GetTagHandle: UString;
    function GetTagSuffix: UString;
    function GetScalarValue: UString;
    function GetScalarStyle: TYamlScalarStyle;
    function GetVersionDirective: IYamlVersionDirective;
    function GetTagDirective: IYamlTagDirective;
    function GetStartMark: IYamlMark;
    function GetEndMark: IYamlMark;

    (** The token type. *)
    property Type_: TYamlTokenType read GetType_;

    (** The token data. *)

      (** The stream start (for @c YAML_STREAM_START_TOKEN). *)
        (** The stream encoding. *)
        property StreamStartEncoding: TYamlEncoding read GetStreamStartEncoding;

      (** The alias (for @c YAML_ALIAS_TOKEN). *)
        (** The alias value. *)
        property AliasValue: UString read GetAliasValue;

      (** The anchor (for @c YAML_ANCHOR_TOKEN). *)
        (** The anchor value. *)
        property AnchorValue: UString read GetAnchorValue;

      (** The tag (for @c YAML_TAG_TOKEN). *)
        (** The tag handle. *)
        property TagHandle: UString read GetTagHandle;
        (** The tag suffix. *)
        property TagSuffix: UString read GetTagSuffix;

      (** The scalar value (for @c YAML_SCALAR_TOKEN). *)
        (** The scalar value. *)
        property ScalarValue: UString read GetScalarValue;
        (** The length of the scalar value. *)
        // ScalarLength
        (** The scalar style. *)
        property ScalarStyle: TYamlScalarStyle read GetScalarStyle;

      (** The version directive (for @c YAML_VERSION_DIRECTIVE_TOKEN). *)
      property VersionDirective: IYamlVersionDirective read GetVersionDirective;

      (** The tag directive (for @c YAML_TAG_DIRECTIVE_TOKEN). *)
      property TagDirective: IYamlTagDirective read GetTagDirective;

    (** The beginning of the token. *)
    property StartMark: IYamlMark read GetStartMark;
    (** The end of the token. *)
    property EndMark: IYamlMark read GetEndMark;

  end;

  (**
   * Free any memory allocated for a token object.
   *
   * @param[in,out]   token   A token object.
   *)

  // yaml_token_delete

  (** @} *)

  (**
   * @defgroup events Events
   * @{
   *)

  (** Event types. *)
  TYamlEventType = YamlThin.TYamlEventType;

  (** The event structure. *)
  IYamlEvent = interface
  ['{12F279D3-BADF-4F5E-8E4E-D895D0A20AF0}']
    function GetType_: TYamlEventType;
    function GetStreamStartEncoding: TYamlEncoding;
    function GetDocumentStartVersionDirective: IYamlVersionDirective;
    function GetDocumentStartTagDirectives: TIYamlTagDirectiveDynArray
    function GetDocumentStartImplicit: Boolean;
    function GetDocumentEndImplicit: Boolean;
    function GetAliasAnchor: UString;
    function GetScalarAnchor: UString;
    function GetScalarTag: UString;
    function GetScalarValue: UString;
    function GetScalarPlainImplicit: Boolean;
    function GetScalarQuotedImplicit: Boolean;
    function GetScalarStyle: TYamlScalarStyle;
    function GetSequenceStartAnchor: UString;
    function GetSequenceStartTag: UString;
    function GetSequenceStartImplicit: Boolean;
    function GetSequenceStartStyle: TYamlSequenceStyle;
    function GetMappingStartAnchor: UString;
    function GetMappingStartTag: UString;
    function GetMappingStartImplicit: Boolean;
    function GetMappingStartStyle: TYamlMappingStyle;
    function GetStartMark: IYamlMark;
    function GetEndMark: IYamlMark;

    (** The event type. *)
    property Type_: TYamlEventType read GetType_;

    (** The event data. *)

      (** The stream parameters (for @c YAML_STREAM_START_EVENT). *)
        (** The document encoding. *)
        property StreamStartEncoding: TYamlEncoding read GetStreamStartEncoding;

      (** The document parameters (for @c YAML_DOCUMENT_START_EVENT). *)
        (** The version directive. *)
        property DocumentStartVersionDirective: IYamlVersionDirective read GetDocumentStartVersionDirective;

        (** The list of tag directives. *)
        property DocumentStartTagDirectives: TIYamlTagDirectiveDynArray read GetDocumentStartTagDirectives;

        (** Is the document indicator implicit? *)
        property DocumentStartImplicit: Boolean read GetDocumentStartImplicit;

      (** The document end parameters (for @c YAML_DOCUMENT_END_EVENT). *)
        (** Is the document end indicator implicit? *)
        property DocumentEndImplicit: Boolean read GetDocumentEndImplicit;

      (** The alias parameters (for @c YAML_ALIAS_EVENT). *)
        (** The anchor. *)
        property AliasAnchor: UString read GetAliasAnchor;

      (** The scalar parameters (for @c YAML_SCALAR_EVENT). *)
        (** The anchor. *)
        property ScalarAnchor: UString read GetScalarAnchor;
        (** The tag. *)
        property ScalarTag: UString read GetScalarTag;
        (** The scalar value. *)
        property ScalarValue: UString read GetScalarValue;
        (** The length of the scalar value. *)
        // ScalarLength
        (** Is the tag optional for the plain style? *)
        property ScalarPlainImplicit: Boolean read GetScalarPlainImplicit;
        (** Is the tag optional for any non-plain style? *)
        property ScalarQuotedImplicit: Boolean read GetScalarQuotedImplicit;
        (** The scalar style. *)
        property ScalarStyle: TYamlScalarStyle read GetScalarStyle;

      (** The sequence parameters (for @c YAML_SEQUENCE_START_EVENT). *)
        (** The anchor. *)
        property SequenceStartAnchor: UString read GetSequenceStartAnchor;
        (** The tag. *)
        property SequenceStartTag: UString read GetSequenceStartTag;
        (** Is the tag optional? *)
        property SequenceStartImplicit: Boolean read GetSequenceStartImplicit;
        (** The sequence style. *)
        property SequenceStartStyle: TYamlSequenceStyle read GetSequenceStartStyle;

      (** The mapping parameters (for @c YAML_MAPPING_START_EVENT). *)
        (** The anchor. *)
        property MappingStartAnchor: UString;
        (** The tag. *)
        property MappingStartTag: UString;
        (** Is the tag optional? *)
        property MappingStartImplicit: Boolean;
        (** The mapping style. *)
        property MappingStartStyle: TYamlMappingStyle;

    (** The beginning of the event. *)
    property StartMark: IYamlMark read GetStartMark;
    (** The end of the event. *)
    property EndMark: IYamlMark read GetEndMark;

  end;

  (**
   * Create the STREAM-START event.
   *
   * @param[out]      event       An empty event object.
   * @param[in]       encoding    The stream encoding.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlStreamStartEvent = class
  public
    class function Create(Encoding: TYamlEncoding): IYamlEvent;
  end;

  (**
   * Create the STREAM-END event.
   *
   * @param[out]      event       An empty event object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlStreamEndEvent = class
  public
    class function Create: IYamlEvent;
  end;

  (**
   * Create the DOCUMENT-START event.
   *
   * The @a implicit argument is considered as a stylistic parameter and may be
   * ignored by the emitter.
   *
   * @param[out]      event                   An empty event object.
   * @param[in]       version_directive       The %YAML directive value or
   *                                          @c NULL.
   * @param[in]       tag_directives_start    The beginning of the %TAG
   *                                          directives list.
   * @param[in]       tag_directives_end      The end of the %TAG directives
   *                                          list.
   * @param[in]       implicit                If the document start indicator is
   *                                          implicit.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlDocumentStartEvent = class
  public
    class function Create(VersionDirective: IYamlVersionDirective;
      TagDirectives: array of IYamlTagDirective;
      Implicit: Boolean): IYamlEvent;
  end;

  (**
   * Create the DOCUMENT-END event.
   *
   * The @a implicit argument is considered as a stylistic parameter and may be
   * ignored by the emitter.
   *
   * @param[out]      event       An empty event object.
   * @param[in]       implicit    If the document end indicator is implicit.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlDocumentEndEvent = class
  public
    class function Create(Implicit: Boolean): IYamlEvent;
  end;

  (**
   * Create an ALIAS event.
   *
   * @param[out]      event       An empty event object.
   * @param[in]       anchor      The anchor value.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlAliasEvent = class
  public
    class function Create(Anchor: UString): IYamlEvent;
  end;

  (**
   * Create a SCALAR event.
   *
   * The @a style argument may be ignored by the emitter.
   *
   * Either the @a tag attribute or one of the @a plain_implicit and
   * @a quoted_implicit flags must be set.
   *
   * @param[out]      event           An empty event object.
   * @param[in]       anchor          The scalar anchor or @c NULL.
   * @param[in]       tag             The scalar tag or @c NULL.
   * @param[in]       value           The scalar value.
   * @param[in]       length          The length of the scalar value.
   * @param[in]       plain_implicit  If the tag may be omitted for the plain
   *                                  style.
   * @param[in]       quoted_implicit If the tag may be omitted for any
   *                                  non-plain style.
   * @param[in]       style           The scalar style.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlScalarEvent = class
  public
    class function Create(Anchor, Tag, Value: UString;
      PlainImplicit, QuotedImplicit: Boolean;
      Style: TYamlScalarStyle): IYamlEvent;
  end;

  (**
   * Create a SEQUENCE-START event.
   *
   * The @a style argument may be ignored by the emitter.
   *
   * Either the @a tag attribute or the @a implicit flag must be set.
   *
   * @param[out]      event       An empty event object.
   * @param[in]       anchor      The sequence anchor or @c NULL.
   * @param[in]       tag         The sequence tag or @c NULL.
   * @param[in]       implicit    If the tag may be omitted.
   * @param[in]       style       The sequence style.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlSequenceStartEvent = class
  public
    class function Create(Anchor, Tag: UString; Implicit: Boolean;
      Style: TYamlSequenceStyle): IYamlEvent;
  end;

  (**
   * Create a SEQUENCE-END event.
   *
   * @param[out]      event       An empty event object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlSequenceEndEvent = class
  public
    class function Create: IYamlEvent;
  end;

  (**
   * Create a MAPPING-START event.
   *
   * The @a style argument may be ignored by the emitter.
   *
   * Either the @a tag attribute or the @a implicit flag must be set.
   *
   * @param[out]      event       An empty event object.
   * @param[in]       anchor      The mapping anchor or @c NULL.
   * @param[in]       tag         The mapping tag or @c NULL.
   * @param[in]       implicit    If the tag may be omitted.
   * @param[in]       style       The mapping style.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlMappingStartEvent = class
  public
    class function Create(Anchor, Tag: UString; Implicit: Boolean;
    Style: TYamlMappingStyle): IYamlEvent;
  end;

  (**
   * Create a MAPPING-END event.
   *
   * @param[out]      event       An empty event object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlMappingEndEvent = class
  public
    class function Create: IYamlEvent;
  end;

  (**
   * Free any memory allocated for an event object.
   *
   * @param[in,out]   event   An event object.
   *)

  // yaml_event_delete

  (** @} *)

  (**
   * @defgroup nodes Nodes
   * @{
   *)

  (** The tag @c !!null with the only possible value: @c null. *)
const yamlNullTag      = YamlThin.yamlNullTag;
  (** The tag @c !!bool with the values: @c true and @c false. *)
const yamlBoolTag      = YamlThin.yamlBoolTag;
  (** The tag @c !!str for string values. *)
const yamlStrTag       = YamlThin.yamlStrTag;
  (** The tag @c !!int for integer values. *)
const yamlIntTag       = YamlThin.yamlIntTag;
  (** The tag @c !!float for float values. *)
const yamlFloatTag     = YamlThin.yamlFloatTag;
  (** The tag @c !!timestamp for date and time values. *)
const yamlTimestampTag = YamlThin.yamlTimestampTag;

  (** The tag @c !!seq is used to denote sequences. *)
const yamlSeqTag       = YamlThin.yamlSeqTag;
  (** The tag @c !!map is used to denote mapping. *)
const yamlMapTag       = YamlThin.yamlMapTag;

  (** The default scalar tag is @c !!str. *)
const yamlDefaultScalarTag    = yamlStrTag;
  (** The default sequence tag is @c !!seq. *)
const yamlDefaultSequenceTag  = yamlSeqTag;
  (** The default mapping tag is @c !!map. *)
const yamlDefaultMappingTag   = yamlMapTag;

  (** Node types. *)
type
  TYamlNodeType = YamlThin.TYamlNodeType;

  (** The forward definition of a document structure. *)
  IYamlDocument = interface;

  (** An element of a sequence node. *)
  IYamlNode = interface;
  TIYamlNodeDynArray = array of IYamlNode;

  (** An element of a mapping node. *)
  TYamlNodePair = record
    (** The key of the element. *)
    Key: IYamlNode;
    (** The value of the element. *)
    Value: IYamlNode;
  end;
  TYamlNodePairDynArray = array of TYamlNodePair;

  (** The node structure. *)
  IYamlNode = interface
  ['{4A158305-AC46-41AA-86E5-10AC082C14D9}']
    function GetDocument: IYamlDocument;
    function GetId: Integer;
    function GetType_: TYamlNodeType;
    function GetTag: UString;
    function GetScalarValue: UString;
    function GetScalarStyle: TYamlScalarStyle;
    function GetSequenceItems: TIYamlNodeDynArray;
    procedure AppendSequenceItem(Item: IYamlNode);
    function GetSequenceStyle: TYamlSequenceStyle;
    function GetMappingPairs: TYamlNodePairDynArray;
    procedure AppendMappingPair(Key, Value: IYamlNode);
    function GetMappingStyle: TYamlMappingStyle;
    function GetStartMark: IYamlMark;
    function GetEndMark: IYamlMark;
    property Document: IYamlDocument read GetDocument;
    property Id: Integer read GetId;

    (** The node type. *)
    property Type_: TYamlNodeType read GetType_;

    (** The node tag. *)
    property Tag: UString read GetTag;

    (** The node data. *)
      (** The scalar parameters (for @c YAML_SCALAR_NODE). *)
        (** The scalar value. *)
        property ScalarValue: UString read GetScalarValue;
        (** The scalar style. *)
        property ScalarStyle: TYamlScalarStyle read GetScalarStyle;

      (** The sequence parameters (for @c YAML_SEQUENCE_NODE). *)
        (** The stack of sequence items. *)
        property SequenceItems: TIYamlNodeDynArray read GetSequenceItems;
        (** The sequence style. *)
        property SequenceStyle: TYamlSequenceStyle read GetSequenceStyle;

      (** The mapping parameters (for @c YAML_MAPPING_NODE). *)
        (** The stack of mapping pairs (key, value). *)
        property MappingPairs: TYamlNodePairDynArray read GetMappingPairs;
        (** The mapping style. *)
        property MappingStyle: TYamlMappingStyle read GetMappingStyle;

    (** The beginning of the node. *)
    property StartMark: IYamlMark read GetStartMark;
    (** The end of the node. *)
    property EndMark: IYamlMark read GetEndMark;

  end;

  (** The document structure. *)
  IYamlDocument = interface
  ['{276D0A02-F531-4DBC-9459-44D2CF6E7AED}']
    function GetNodes: TIYamlNodeDynArray;
    function GetRootNode: IYamlNode;
    function GetVersionDirective: IYamlVersionDirective;
    function GetTagDirectives: TIYamlTagDirectiveDynArray;
    function GetStartImplicit: Boolean;
    function GetEndImplicit: Boolean;
    function GetStartMark: IYamlMark;
    function GetEndMark: IYamlMark;

    function CreateScalar(Tag, Value: UString; Style: TYamlScalarStyle): IYamlNode;
    function CreateSequence(Tag: UString; Style: TYamlScalarStyle): IYamlNode;
    function CreateMapping(Tag: UString; Style: TYamlMappingStyle): IYamlNode;

    (** The document nodes. *)
    property Nodes: TIYamlNodeDynArray read GetNodes;
    property RootNode: IYamlNode read GetRootNode;

    (** The version directive. *)
    property VersionDirective: IYamlVersionDirective read GetVersionDirective;

    (** The list of tag directives. *)
    property TagDirectives: TIYamlTagDirectiveDynArray read GetTagDirectives;

    (** Is the document start indicator implicit? *)
    property StartImplicit: Boolean read GetStartImplicit;
    (** Is the document end indicator implicit? *)
    property EndImplicit: Boolean read GetEndImplicit;

    (** The beginning of the document. *)
    property StartMark: IYamlMark;
    (** The end of the document. *)
    property EndMark: IYamlMark;

  end;

  (**
   * Create a YAML document.
   *
   * @param[out]      document                An empty document object.
   * @param[in]       version_directive       The %YAML directive value or
   *                                          @c NULL.
   * @param[in]       tag_directives_start    The beginning of the %TAG
   *                                          directives list.
   * @param[in]       tag_directives_end      The end of the %TAG directives
   *                                          list.
   * @param[in]       start_implicit          If the document start indicator is
   *                                          implicit.
   * @param[in]       end_implicit            If the document end indicator is
   *                                          implicit.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlDocument = class
  public
    class function Create(VersionDirective: IYamlVersionDirective;
      TagDirectives: array of IYamlTagDirective;
      StartImplicit, EndImplicit: Boolean): IYamlDocument;
  end;

  (**
   * Delete a YAML document and all its nodes.
   *
   * @param[in,out]   document        A document object.
   *)

  // yaml_document_delete

  (**
   * Get a node of a YAML document.
   *
   * The pointer returned by this function is valid until any of the functions
   * modifying the documents are called.
   *
   * @param[in]       document        A document object.
   * @param[in]       index           The node id.
   *
   * @returns the node objct or @c NULL if @c node_id is out of range.
   *)

  // yaml_document_get_node

  (**
   * Get the root of a YAML document node.
   *
   * The root object is the first object added to the document.
   *
   * The pointer returned by this function is valid until any of the functions
   * modifying the documents are called.
   *
   * An empty document produced by the parser signifies the end of a YAML
   * stream.
   *
   * @param[in]       document        A document object.
   *
   * @returns the node object or @c NULL if the document is empty.
   *)

  // yaml_document_get_root_node

  (**
   * Create a SCALAR node and attach it to the document.
   *
   * The @a style argument may be ignored by the emitter.
   *
   * @param[in,out]   document        A document object.
   * @param[in]       tag             The scalar tag.
   * @param[in]       value           The scalar value.
   * @param[in]       length          The length of the scalar value.
   * @param[in]       style           The scalar style.
   *
   * @returns the node id or @c 0 on error.
   *)

  // yaml_document_add_scalar

  (**
   * Create a SEQUENCE node and attach it to the document.
   *
   * The @a style argument may be ignored by the emitter.
   *
   * @param[in,out]   document    A document object.
   * @param[in]       tag         The sequence tag.
   * @param[in]       style       The sequence style.
   *
   * @returns the node id or @c 0 on error.
   *)

  // yaml_document_add_sequence

  (**
   * Create a MAPPING node and attach it to the document.
   *
   * The @a style argument may be ignored by the emitter.
   *
   * @param[in,out]   document    A document object.
   * @param[in]       tag         The sequence tag.
   * @param[in]       style       The sequence style.
   *
   * @returns the node id or @c 0 on error.
   *)

  // yaml_document_add_mapping

  (**
   * Add an item to a SEQUENCE node.
   *
   * @param[in,out]   document    A document object.
   * @param[in]       sequence    The sequence node id.
   * @param[in]       item        The item node id.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  // yaml_document_append_sequence_item

  (**
   * Add a pair of a key and a value to a MAPPING node.
   *
   * @param[in,out]   document    A document object.
   * @param[in]       mapping     The mapping node id.
   * @param[in]       key         The key node id.
   * @param[in]       value       The value node id.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  // yaml_document_append_mapping_pair

  (** @} *)

  (**
   * @defgroup parser Parser Definitions
   * @{
   *)

  (**
   * The prototype of a read handler.
   *
   * The read handler is called when the parser needs to read more bytes from the
   * source.  The handler should write not more than @a size bytes to the @a
   * buffer.  The number of written bytes should be set to the @a length variable.
   *
   * @param[in,out]   data        A pointer to an application data specified by
   *                              yaml_parser_set_input().
   * @param[out]      buffer      The buffer to write the data from the source.
   * @param[in]       size        The size of the buffer.
   * @param[out]      size_read   The actual number of bytes read from the source.
   *
   * @returns On success, the handler should return @c 1.  If the handler failed,
   * the returned value should be @c 0.  On EOF, the handler should set the
   * @a size_read to @c 0 and return @c 1.
   *)

  // yaml_read_handler_t

  (**
   * This structure holds information about a potential simple key.
   *)

  // yaml_simple_key_t

  (**
   * The states of the parser.
   *)
  // yaml_parser_state_t

  (**
   * This structure holds aliases data.
   *)

  // yaml_alias_data_t

  (**
   * The parser structure.
   *
   * All members are internal.  Manage the structure using the @c yaml_parser_
   * family of functions.
   *)

  IYamlTokenParser = interface
  ['{89C50981-0DB4-4E54-8412-FE9FD999B608}']
    function Next(var Token: IYamlToken): Boolean;
  end;
  IYamlEventParser = interface
  ['{48F38085-102F-44C3-A05B-9D2FCA912731}']
    function Next(var Event: IYamlEvent): Boolean;
  end;
  IYamlDocumentParser = interface
  ['{6FDBFA28-C462-4A78-ACF5-974021ADBE67}']
    function Next(var Document: IYamlDocument): Boolean;
  end;
  IYamlParserFactory = interface
  ['{AB8C3012-1294-423F-8B5A-91BB884E6A05}']
    function CreateTokenParser: IYamlTokenParser;
    function CreateEventParser: IYamlEventParser;
    function CreateDocumentParser: IYamlDocumentParser;
  end;

  (**
   * Initialize a parser.
   *
   * This function creates a new parser object.  An application is responsible
   * for destroying the object using the yaml_parser_delete() function.
   *
   * @param[out]      parser  An empty parser object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  // yaml_parser_initialize

  (**
   * Destroy a parser.
   *
   * @param[in,out]   parser  A parser object.
   *)

  // yaml_parser_delete

  (**
   * Set a string input.
   *
   * Note that the @a input pointer must be valid while the @a parser object
   * exists.  The application is responsible for destroing @a input after
   * destroying the @a parser.
   *
   * @param[in,out]   parser  A parser object.
   * @param[in]       input   A source data.
   * @param[in]       size    The length of the source data in bytes.
   *)

function YamlParser(const Input; Size: Integer;
  Encoding: TYamlEncoding = yamlAnyEncoding): IYamlParserFactory; overload;
function YamlParser(Input: PAnsiChar; Size: Integer;
  Encoding: TYamlEncoding = yamlAnyEncoding): IYamlParserFactory; overload;
function YamlParser(Input: UTF8String;
  Encoding: TYamlEncoding = yamlUtf8Encoding): IYamlParserFactory; overload;
function YamlParser(Input: WideString;
  Encoding: TYamlEncoding = yamlUtf16leEncoding): IYamlParserFactory; overload;
function YamlParser(Input: PWideChar; SizeInWideChars: Integer;
  Encoding: TYamlEncoding = yamlUtf16leEncoding): IYamlParserFactory; overload;
function YamlParser(Input: TByteDynArray;
  Encoding: TYamlEncoding = yamlAnyEncoding): IYamlParserFactory; overload;

  (**
   * Set a file input.
   *
   * @a file should be a file object open for reading.  The application is
   * responsible for closing the @a file.
   *
   * @param[in,out]   parser  A parser object.
   * @param[in]       file    An open file.
   *)

function YamlParser(Input: TStream;
  Encoding: TYamlEncoding = yamlAnyEncoding): IYamlParserFactory; overload;
//type

  (**
   * Set a generic input handler.
   *
   * @param[in,out]   parser  A parser object.
   * @param[in]       handler A read handler.
   * @param[in]       data    Any application data for passing to the read
   *                          handler.
   *)

  // yaml_parser_set_input

  (**
   * Set the source encoding.
   *
   * @param[in,out]   parser      A parser object.
   * @param[in]       encoding    The source encoding.
   *)

  // yaml_parser_set_encoding

  (**
   * Scan the input stream and produce the next token.
   *
   * Call the function subsequently to produce a sequence of tokens corresponding
   * to the input stream.  The initial token has the type
   * @c YAML_STREAM_START_TOKEN while the ending token has the type
   * @c YAML_STREAM_END_TOKEN.
   *
   * An application is responsible for freeing any buffers associated with the
   * produced token object using the @c yaml_token_delete function.
   *
   * An application must not alternate the calls of yaml_parser_scan() with the
   * calls of yaml_parser_parse() or yaml_parser_load(). Doing this will break
   * the parser.
   *
   * @param[in,out]   parser      A parser object.
   * @param[out]      token       An empty token object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  // yaml_parser_scan

  (**
   * Parse the input stream and produce the next parsing event.
   *
   * Call the function subsequently to produce a sequence of events corresponding
   * to the input stream.  The initial event has the type
   * @c YAML_STREAM_START_EVENT while the ending event has the type
   * @c YAML_STREAM_END_EVENT.
   *
   * An application is responsible for freeing any buffers associated with the
   * produced event object using the yaml_event_delete() function.
   *
   * An application must not alternate the calls of yaml_parser_parse() with the
   * calls of yaml_parser_scan() or yaml_parser_load(). Doing this will break the
   * parser.
   *
   * @param[in,out]   parser      A parser object.
   * @param[out]      event       An empty event object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  // yaml_parser_parse

  (**
   * Parse the input stream and produce the next YAML document.
   *
   * Call this function subsequently to produce a sequence of documents
   * constituting the input stream.
   *
   * If the produced document has no root node, it means that the document
   * end has been reached.
   *
   * An application is responsible for freeing any data associated with the
   * produced document object using the yaml_document_delete() function.
   *
   * An application must not alternate the calls of yaml_parser_load() with the
   * calls of yaml_parser_scan() or yaml_parser_parse(). Doing this will break
   * the parser.
   *
   * @param[in,out]   parser      A parser object.
   * @param[out]      document    An empty document object.
   *
   * @return @c 1 if the function succeeded, @c 0 on error.
   *)

  // yaml_parser_load

  (** @} *)




implementation

// Thick binding

type
  TYamlVersionImpl = class(TInterfacedObject, IYamlVersion)
  public
    function GetAsString: string;
    function GetMajor: Integer;
    function GetMinor: Integer;
    function GetPatch: Integer;
    property AsString: string read GetAsString;
    property Major: Integer read GetMajor;
    property Minor: Integer read GetMinor;
    property Patch: Integer read GetPatch;
  end;

function YamlVersion: IYamlVersion;
begin
  Result := TYamlVersionImpl.Create;
end;

function TYamlVersionImpl.GetAsString: string;
begin
  Result := _yaml_get_version_string;
end;

function TYamlVersionImpl.GetMajor: Integer;
var
  Minor, Patch: Integer;
begin
  _yaml_get_version(Result, Minor, Patch);
end;

function TYamlVersionImpl.GetMinor: Integer;
var
  Major, Patch: Integer;
begin
  _yaml_get_version(Major, Result, Patch);
end;

function TYamlVersionImpl.GetPatch: Integer;
var
  Major, Minor: Integer;
begin
  _yaml_get_version(Major, Minor, Result);
end;



end.
