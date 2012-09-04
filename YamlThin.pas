(**
 * @file yamlthin.pas
 * @brief Thin binding for libyaml.
 *)

{$Z4} // Size of enumerations is 4, don't remove!!!

{$WARN UNSAFE_TYPE OFF} // PAnsiChar

unit YamlThin;

interface

uses
  SysUtils, Classes;

//-//-//-//-//-//-//-//-//-//
// yaml.h

(**
 * @defgroup version Version Information
 * @{
 *)

(**
 * Get the library version as a string.
 *
 * @returns The function returns the pointer to a static string of the form
 * @c "X.Y.Z", where @c X is the major version number, @c Y is a minor version
 * number, and @c Z is the patch version number.
 *)

function _yaml_get_version_string: PAnsiChar; cdecl; external;

(**
 * Get the library version numbers.
 *
 * @param[out]      major   Major version number.
 * @param[out]      minor   Minor version number.
 * @param[out]      patch   Patch version number.
 *)

procedure _yaml_get_version(var major, minor, patch: Integer); cdecl; external;

(** @} *)

(**
 * @defgroup basic Basic Types
 * @{
 *)

(** The character type (UTF-8 octet). *)
type PYamlChar = type PAnsiChar;

(** The version directive data. *)
type
  TYamlVersionDirective = record
    (** The major version number. *)
    major: Integer;
    (** The minor version number. *)
    minor: Integer;
  end;
  PYamlVersionDirective = ^TYamlVersionDirective;

(** The tag directive data. *)
type
  TYamlTagDirective = record
    (** The tag handle. *)
    handle: PYamlChar;
    (** The tag prefix. *)
    prefix: PYamlChar;
  end;
  PYamlTagDirective = ^TYamlTagDirective;

(** The stream encoding. *)
type
  TYamlEncoding = (
    (** Let the parser choose the encoding. *)
    yamlAnyEncoding,
    (** The default UTF-8 encoding. *)
    yamlUtf8Encoding,
    (** The UTF-16-LE encoding with BOM. *)
    yamlUtf16leEncoding,
    (** The UTF-16-BE encoding with BOM. *)
    yamlUtf16beEncoding
  );

(** Line break types. *)

  TYamlBreak = (
    (** Let the parser choose the break type. *)
    yamlAnyBreak,
    (** Use CR for line breaks (Mac style). *)
    yamlCrBreak,
    (** Use LN for line breaks (Unix style). *)
    yamlLnBreak,
    (** Use CR LN for line breaks (DOS style). *)
    yamlCrLnBreak
  );

(** Many bad things could happen with the parser and emitter. *)
type TYamlErrorType = (
  (** No error is produced. *)
  yamlNoError,

  (** Cannot allocate or reallocate a block of memory. *)
  yamlMemoryError,

  (** Cannot read or decode the input stream. *)
  yamlReaderError,
  (** Cannot scan the input stream. *)
  yamlScannerError,
  (** Cannot parse the input stream. *)
  yamlParserError,
  (** Cannot compose a YAML document. *)
  yamlComposerError,

  (** Cannot write to the output stream. *)
  yamlWriterError,
  (** Cannot emit a YAML stream. *)
  yamlEmitterError
);

(** The pointer position. *)
type
  TYamlMark = record
    (** The position index. *)
    index: Integer;

    (** The position line. *)
    line: Integer;

    (** The position column. *)
    column: Integer;
  end;
  PYamlMark = ^TYamlMark;

(** @} *)

(**
 * @defgroup styles Node Styles
 * @{
 *)

(** Scalar styles. *)
type TYamlScalarStyle = (
  (** Let the emitter choose the style. *)
  yamlAnyScalarStyle,

  (** The plain scalar style. *)
  yamlPlainScalarStyle,

  (** The single-quoted scalar style. *)
  yamlSingleQuotedScalarStyle,
  (** The double-quoted scalar style. *)
  yamlDoubleQuotedScalarStyle,

  (** The literal scalar style. *)
  yamlLiteralScalarStyle,
  (** The folded scalar style. *)
  yamlFoldedScalarStyle
);

(** Sequence styles. *)
type TYamlSequenceStyle = (
  (** Let the emitter choose the style. *)
  yamlAnySequenceStyle,

  (** The block sequence style. *)
  yamlBlockSequenceStyle,
  (** The flow sequence style. *)
  yamlFlowSequenceStyle
);

(** Mapping styles. *)
type TYamlMappingStyle = (
  (** Let the emitter choose the style. *)
  yamlAnyMappingStyle,

  (** The block mapping style. *)
  yamlBlockMappingStyle,
  (** The flow mapping style. *)
  yamlFlowMappingStyle
(*  YAML_FLOW_SET_MAPPING_STYLE   *)
);

(** @} *)

(**
 * @defgroup tokens Tokens
 * @{
 *)

(** Token types. *)
type TYamlTokenType = (
  (** An empty token. *)
  yamlNoToken,

  (** A STREAM-START token. *)
  yamlStreamStartToken,
  (** A STREAM-END token. *)
  yamlStreamEndToken,

  (** A VERSION-DIRECTIVE token. *)
  yamlVersionDirectiveToken,
  (** A TAG-DIRECTIVE token. *)
  yamlTagDirectiveToken,
  (** A DOCUMENT-START token. *)
  yamlDocumentStartToken,
  (** A DOCUMENT-END token. *)
  yamlDocumentEndToken,

  (** A BLOCK-SEQUENCE-START token. *)
  yamlBlockSequenceStartToken,
  (** A BLOCK-SEQUENCE-END token. *)
  yamlBlockMappingStartToken,
  (** A BLOCK-END token. *)
  yamlBlockEndToken,

  (** A FLOW-SEQUENCE-START token. *)
  yamlFlowSequenceStartToken,
  (** A FLOW-SEQUENCE-END token. *)
  yamlFlowSequenceEndToken,
  (** A FLOW-MAPPING-START token. *)
  yamlFlowMappingStartToken,
  (** A FLOW-MAPPING-END token. *)
  yamlFlowMappingEndToken,

  (** A BLOCK-ENTRY token. *)
  yamlBlockEntryToken,
  (** A FLOW-ENTRY token. *)
  yamlFlowEntryToken,
  (** A KEY token. *)
  yamlKeyToken,
  (** A VALUE token. *)
  yamlValueToken,

  (** An ALIAS token. *)
  yamlAliasToken,
  (** An ANCHOR token. *)
  yamlAnchorToken,
  (** A TAG token. *)
  yamlTagToken,
  (** A SCALAR token. *)
  yamlScalarToken
);

(** The token structure. *)
type
  TYamlTokenData = record

    (** The token type. *)
    case type_: TYamlTokenType of

    (** The token data. *)

      (** The stream start (for @c YAML_STREAM_START_TOKEN). *)
      yamlStreamStartToken: (
        (** The stream encoding. *)
        stream_start_encoding: TYamlEncoding;
      );

      (** The alias (for @c YAML_ALIAS_TOKEN). *)
      yamlAliasToken: (
        (** The alias value. *)
        alias_value: PYamlChar;
      );

      (** The anchor (for @c YAML_ANCHOR_TOKEN). *)
      yamlAnchorToken: (
        (** The anchor value. *)
        anchor_value: PYamlChar;
      );

      (** The tag (for @c YAML_TAG_TOKEN). *)
      yamlTagToken: (
        (** The tag handle. *)
        tag_handle: PYamlChar;
        (** The tag suffix. *)
        tag_suffix: PYamlChar;
      );

      (** The scalar value (for @c YAML_SCALAR_TOKEN). *)
      yamlScalarToken: (
        (** The scalar value. *)
        scalar_value: PYamlChar;
        (** The length of the scalar value. *)
        scalar_length: Integer;
        (** The scalar style. *)
        scalar_style: TYamlScalarStyle;
      );

      (** The version directive (for @c YAML_VERSION_DIRECTIVE_TOKEN). *)
      yamlVersionDirectiveToken: (
        (** The major version number. *)
        version_directive_major: Integer;
        (** The minor version number. *)
        version_directive_minor: Integer;
      );

      (** The tag directive (for @c YAML_TAG_DIRECTIVE_TOKEN). *)
      yamlTagDirectiveToken: (
        (** The tag handle. *)
        tag_directive_handle: PYamlChar;
        (** The tag prefix. *)
        tag_directive_prefix: PYamlChar;
      );

  end;
  TYamlToken = record
    data: TYamlTokenData;

    (** The beginning of the token. *)
    start_mark: TYamlMark;
    (** The end of the token. *)
    end_mark: TYamlMark;

  end;
  type PYamlToken = ^TYamlToken;

(**
 * Free any memory allocated for a token object.
 *
 * @param[in,out]   token   A token object.
 *)

procedure _yaml_token_delete(token: PYamlToken); cdecl; external;

(** @} *)

(**
 * @defgroup events Events
 * @{
 *)

(** Event types. *)
type TYamlEventType = (
  (** An empty event. *)
  yamlNoEvent,

  (** A STREAM-START event. *)
  yamlStreamStartEvent,
  (** A STREAM-END event. *)
  yamlStreamEndEvent,

  (** A DOCUMENT-START event. *)
  yamlDocumentStartEvent,
  (** A DOCUMENT-END event. *)
  yamlDocumentEndEvent,

  (** An ALIAS event. *)
  yamlAliasEvent,
  (** A SCALAR event. *)
  yamlScalarEvent,

  (** A SEQUENCE-START event. *)
  yamlSequenceStartEvent,
  (** A SEQUENCE-END event. *)
  yamlSequenceEndEvent,

  (** A MAPPING-START event. *)
  yamlMappingStartEvent,
  (** A MAPPING-END event. *)
  yamlMappingEndEvent
);

(** The event structure. *)
type
  TYamlEventData = record

    (** The event type. *)
    case type_: TYamlEventType of

    (** The event data. *)

      (** The stream parameters (for @c YAML_STREAM_START_EVENT). *)
      yamlStreamStartEvent: (
        (** The document encoding. *)
        stream_start_encoding: TYamlEncoding;
      );

      (** The document parameters (for @c YAML_DOCUMENT_START_EVENT). *)
      yamlDocumentStartEvent: (
        (** The version directive. *)
        document_start_version_directive: PYamlVersionDirective;

        (** The list of tag directives. *)
          (** The beginning of the tag directives list. *)
          document_start_tag_directives_start: PYamlTagDirective;
          (** The end of the tag directives list. *)
          document_start_tag_directives_end: PYamlTagDirective;

        (** Is the document indicator implicit? *)
        document_start_implicit: Integer;
      );

      (** The document end parameters (for @c YAML_DOCUMENT_END_EVENT). *)
      yamlDocumentEndEvent: (
        (** Is the document end indicator implicit? *)
        document_end_implicit: Integer;
      );

      (** The alias parameters (for @c YAML_ALIAS_EVENT). *)
      yamlAliasEvent: (
        (** The anchor. *)
        alias_anchor: PYamlChar;
      );

      (** The scalar parameters (for @c YAML_SCALAR_EVENT). *)
      yamlScalarEvent: (
        (** The anchor. *)
        scalar_anchor: PYamlChar;
        (** The tag. *)
        scalar_tag: PYamlChar;
        (** The scalar value. *)
        scalar_value: PYamlChar;
        (** The length of the scalar value. *)
        scalar_length: Integer;
        (** Is the tag optional for the plain style? *)
        scalar_plain_implicit: Integer;
        (** Is the tag optional for any non-plain style? *)
        scalar_quoted_implicit: Integer;
        (** The scalar style. *)
        scalar_style: TYamlScalarStyle;
      );

      (** The sequence parameters (for @c YAML_SEQUENCE_START_EVENT). *)
      yamlSequenceStartEvent: (
        (** The anchor. *)
        sequence_start_anchor: PYamlChar;
        (** The tag. *)
        sequence_start_tag: PYamlChar;
        (** Is the tag optional? *)
        sequence_start_implicit: Integer;
        (** The sequence style. *)
        sequence_start_style: TYamlSequenceStyle;
      );

      (** The mapping parameters (for @c YAML_MAPPING_START_EVENT). *)
      yamlMappingStartEvent: (
        (** The anchor. *)
        mapping_start_anchor: PYamlChar;
        (** The tag. *)
        mapping_start_tag: PYamlChar;
        (** Is the tag optional? *)
        mapping_start_implicit: Integer;
        (** The mapping style. *)
        mapping_start_style: TYamlMappingStyle;
      );

  end;
  TYamlEvent = record
    data: TYamlEventData;

    (** The beginning of the event. *)
    start_mark: TYamlMark;
    (** The end of the event. *)
    end_mark: TYamlMark;

  end;
  PYamlEvent = ^TYamlEvent;

(**
 * Create the STREAM-START event.
 *
 * @param[out]      event       An empty event object.
 * @param[in]       encoding    The stream encoding.
 *
 * @returns @c 1 if the function succeeded, @c 0 on error.
 *)

function _yaml_stream_start_event_initialize(out event : TYamlEvent;
  encoding: TYamlEncoding): Integer; cdecl; external;

(**
 * Create the STREAM-END event.
 *
 * @param[out]      event       An empty event object.
 *
 * @returns @c 1 if the function succeeded, @c 0 on error.
 *)

function _yaml_stream_end_event_initialize(out event: TYamlEvent): Integer;
  cdecl; external;

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

function _yaml_document_start_event_initialize(out event: TYamlEvent;
  version_directive: PYamlVersionDirective;
  tag_directives_start, tag_directives_end: PYamlTagDirective;
  implicit: Integer): Integer; cdecl; external;

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

function _yaml_document_end_event_initialize(out event: TYamlEvent;
  implicit: Integer): Integer; cdecl; external;

(**
 * Create an ALIAS event.
 *
 * @param[out]      event       An empty event object.
 * @param[in]       anchor      The anchor value.
 *
 * @returns @c 1 if the function succeeded, @c 0 on error.
 *)

function _yaml_alias_event_initialize(out event: TYamlEvent;
  anchor: PYamlChar): Integer; cdecl; external;

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

function _yaml_scalar_event_initialize(out event: TYamlEvent;
  anchor, tag, value: PYamlChar;
  length, plain_implicit, quoted_implicit: Integer;
  style: TYamlScalarStyle): Integer; cdecl; external;

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

function _yaml_sequence_start_event_initialize(out event: TYamlEvent;
  anchor, tag: PYamlChar; implicit: Integer;
  style: TYamlSequenceStyle): Integer; cdecl; external;

(**
 * Create a SEQUENCE-END event.
 *
 * @param[out]      event       An empty event object.
 *
 * @returns @c 1 if the function succeeded, @c 0 on error.
 *)

function _yaml_sequence_end_event_initialize(out event: TYamlEvent): Integer;
  cdecl; external;

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

function _yaml_mapping_start_event_initialize(out event: TYamlEvent;
  anchor, tag: PYamlChar; implicit: Integer;
  style: TYamlMappingStyle): Integer; cdecl; external;

(**
 * Create a MAPPING-END event.
 *
 * @param[out]      event       An empty event object.
 *
 * @returns @c 1 if the function succeeded, @c 0 on error.
 *)

function _yaml_mapping_end_event_initialize(out event: TYamlEvent): Integer;
  cdecl; external;

(**
 * Free any memory allocated for an event object.
 *
 * @param[in,out]   event   An event object.
 *)

procedure _yaml_event_delete(var event: TYamlEvent); cdecl; external;

(** @} *)

(**
 * @defgroup nodes Nodes
 * @{
 *)

(** The tag @c !!null with the only possible value: @c null. *)
const yamlNullTag      = 'tag:yaml.org,2002:null';
(** The tag @c !!bool with the values: @c true and @c false. *)
const yamlBoolTag      = 'tag:yaml.org,2002:bool';
(** The tag @c !!str for string values. *)
const yamlStrTag       = 'tag:yaml.org,2002:str';
(** The tag @c !!int for integer values. *)
const yamlIntTag       = 'tag:yaml.org,2002:int';
(** The tag @c !!float for float values. *)
const yamlFloatTag     = 'tag:yaml.org,2002:float';
(** The tag @c !!timestamp for date and time values. *)
const yamlTimestampTag = 'tag:yaml.org,2002:timestamp';

(** The tag @c !!seq is used to denote sequences. *)
const yamlSeqTag       = 'tag:yaml.org,2002:seq';
(** The tag @c !!map is used to denote mapping. *)
const yamlMapTag       = 'tag:yaml.org,2002:map';

(** The default scalar tag is @c !!str. *)
const yamlDefaultScalarTag    = yamlStrTag;
(** The default sequence tag is @c !!seq. *)
const yamlDefaultSequenceTag  = yamlSeqTag;
(** The default mapping tag is @c !!map. *)
const yamlDefaultMappingTag   = yamlMapTag;

(** Node types. *)
type TYamlNodeType = (
  (** An empty node. *)
  yamlNoNode,

  (** A scalar node. *)
  yamlScalarNode,
  (** A sequence node. *)
  yamlSequenceNode,
  (** A mapping node. *)
  yamlMappingNode
);

(** The forward definition of a document node structure. *)
//type PYamlNode = type Pointer;

(** An element of a sequence node. *)
type
  TYamlNodeItem = Integer;
  PYamlNodeItem = ^TYamlNodeItem;

(** An element of a mapping node. *)
type
  TYamlNodePair = record
    (** The key of the element. *)
    key: Integer;
    (** The value of the element. *)
    value: Integer;
  end;
  PYamlNodePair = ^TYamlNodePair;

(** The node structure. *)
type
  TYamlNodeData = record
    case TYamlNodeType of
      (** The scalar parameters (for @c YAML_SCALAR_NODE). *)
      yamlScalarNode: (
        (** The scalar value. *)
        scalar_value: PYamlChar;
        (** The length of the scalar value. *)
        scalar_length: Integer;
        (** The scalar style. *)
        scalar_style: TYamlScalarStyle;
      );

      (** The sequence parameters (for @c YAML_SEQUENCE_NODE). *)
      yamlSequenceNode: (
        (** The stack of sequence items. *)
          (** The beginning of the stack. *)
          sequence_items_start: PYamlNodeItem;
          (** The end of the stack. *)
          sequence_items_end: PYamlNodeItem;
          (** The top of the stack. *)
          sequence_items_top: PYamlNodeItem;
        (** The sequence style. *)
        sequence_style: TYamlSequenceStyle;
      );

      (** The mapping parameters (for @c YAML_MAPPING_NODE). *)
      yamlMappingNode: (
        (** The stack of mapping pairs (key, value). *)
          (** The beginning of the stack. *)
          mapping_pairs_start: PYamlNodePair;
          (** The end of the stack. *)
          mapping_pairs_end: PYamlNodePair;
          (** The top of the stack. *)
          mapping_pairs_top: PYamlNodePair;
        (** The mapping style. *)
        mapping_style: TYamlMappingStyle;
      );

  end;
  TYamlNode = record

    (** The node type. *)
    type_: TYamlNodeType;

    (** The node tag. *)
    tag: PYamlChar;

    (** The node data. *)
    data: TYamlNodeData;

    (** The beginning of the node. *)
    start_mark: TYamlMark;
    (** The end of the node. *)
    end_mark: TYamlMark;

  end;
  PYamlNode = ^TYamlNode;

(** The document structure. *)
type
  TYamlDocument = record

    (** The document nodes. *)
      (** The beginning of the stack. *)
      nodes_start: PYamlNode;
      (** The end of the stack. *)
      nodes_end: PYamlNode;
      (** The top of the stack. *)
      nodes_top: PYamlNode;

    (** The version directive. *)
    version_directive: TYamlVersionDirective;

    (** The list of tag directives. *)
      (** The beginning of the tag directives list. *)
      tag_directives_start: PYamlTagDirective;
      (** The end of the tag directives list. *)
      tag_directives_end: PYamlTagDirective;

    (** Is the document start indicator implicit? *)
    start_implicit: Integer;
    (** Is the document end indicator implicit? *)
    end_implicit: Integer;

    (** The beginning of the document. *)
    start_mark: TYamlMark;
    (** The end of the document. *)
    end_mark: TYamlMark;

  end;
  PYamlDocument = ^TYamlDocument;

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

function _yaml_document_initialize(out document: TYamlDocument;
  version_directive: PYamlVersionDirective;
  tag_directives_start, tag_directives_end: PYamlTagDirective;
  start_implicit, end_implicit: Integer): Integer; cdecl; external;

(**
 * Delete a YAML document and all its nodes.
 *
 * @param[in,out]   document        A document object.
 *)

procedure _yaml_document_delete(var document: TYamlDocument); cdecl; external;

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

function _yaml_document_get_node(document: PYamlDocument; idx: Integer):
  PYamlNode; cdecl; external;

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

function _yaml_document_get_root_node(document: PYamlDocument): PYamlNode;
  cdecl; external;

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

function _yaml_document_add_scalar(var document: TYamlDocument;
  tag, value: PYamlChar; length: Integer; style: TYamlScalarStyle):
  Integer; cdecl; external;

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

function _yaml_document_add_sequence(var document: TYamlDocument;
  tag: PYamlChar; style: TYamlScalarStyle): Integer; cdecl; external;

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

function _yaml_document_add_mapping(var document: TYamlDocument;
  tag: PYamlChar; style: TYamlMappingStyle): Integer; cdecl; external;

(**
 * Add an item to a SEQUENCE node.
 *
 * @param[in,out]   document    A document object.
 * @param[in]       sequence    The sequence node id.
 * @param[in]       item        The item node id.
 *
 * @returns @c 1 if the function succeeded, @c 0 on error.
 *)

function _yaml_document_append_sequence_item(var document: TYamlDocument;
  sequence, item: Integer): Integer; cdecl; external;

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

function _yaml_document_append_mapping_pair(var document: TYamlDocument;
  mapping, key, value: Integer): Integer; cdecl; external;

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

type TYamlReadHandler = function(var data; buffer: PAnsiChar;
  size: Integer; var size_read: Integer): Integer; cdecl;

(**
 * This structure holds information about a potential simple key.
 *)

type
  TYamlSimpleKey = record
    (** Is a simple key possible? *)
    possible: Integer;

    (** Is a simple key required? *)
    required: Integer;

    (** The number of the token. *)
    token_number: Integer;

    (** The position mark. *)
    mark: TYamlMark;
  end;
  PYamlSimpleKey = ^TYamlSimpleKey;

(**
 * The states of the parser.
 *)
// yaml_parser_state_t

(**
 * This structure holds aliases data.
 *)

type
  TYamlAliasData = record
    (** The anchor. *)
    anchor: PYamlChar;
    (** The node id. *)
    index: Integer;
    (** The anchor mark. *)
    mark: TYamlMark;
  end;
  PYamlAliasData = ^TYamlAliasData;

(**
 * The parser structure.
 *
 * All members are internal.  Manage the structure using the @c yaml_parser_
 * family of functions.
 *)

type
  TYamlParserError = record

    (**
     * @name Error handling
     * @{
     *)

    (** Error type. *)
    error: TYamlErrorType;
    (** Error description. *)
    problem: PYamlChar;
    (** The byte about which the problem occured. *)
    problem_offset: Integer;
    (** The problematic value (@c -1 is none). *)
    problem_value: Integer;
    (** The problem position. *)
    problem_mark: TYamlMark;
    (** The error context. *)
    context: PYamlChar;
    (** The context position. *)
    context_mark: TYamlMark;

    (**
     * @}
     *)
     
  end;
  PYamlParser = type Pointer;
  PYamlParserError = ^TYamlParserError;
var
  SizeOfTYamlParser : Integer; // initialized at runtime

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

function _yaml_parser_initialize(parser: PYamlParser): Integer; cdecl; external;

(**
 * Destroy a parser.
 *
 * @param[in,out]   parser  A parser object.
 *)

procedure _yaml_parser_delete(parser: PYamlParser); cdecl; external;

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

procedure _yaml_parser_set_input_string(parser: PYamlParser;
  input: PAnsiChar; size: Integer); cdecl; external;

(**
 * Set a file input.
 *
 * @a file should be a file object open for reading.  The application is
 * responsible for closing the @a file.
 *
 * @param[in,out]   parser  A parser object.
 * @param[in]       file    An open file.
 *)

procedure _yaml_parser_set_input_file(parser: PYamlParser;
  file_: TStream); cdecl; external;

(**
 * Set a generic input handler.
 *
 * @param[in,out]   parser  A parser object.
 * @param[in]       handler A read handler.
 * @param[in]       data    Any application data for passing to the read
 *                          handler.
 *)

procedure _yaml_parser_set_input(parser: PYamlParser;
  handler: TYamlReadHandler; var data); cdecl; external;

(**
 * Set the source encoding.
 *
 * @param[in,out]   parser      A parser object.
 * @param[in]       encoding    The source encoding.
 *)

procedure _yaml_parser_set_encoding(parser: PYamlParser;
  encoding: TYamlEncoding); cdecl; external;

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

function _yaml_parser_scan(parser: PYamlParser; token: PYamlToken): Integer; cdecl; external;

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

function _yaml_parser_parse(parser: PYamlParser; event: PYamlEvent): Integer;
  cdecl; external;

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

function _yaml_parser_load(parser: PYamlParser; document: PYamlDocument):
  Integer; cdecl; external;

(** @} *)

(**
 * @defgroup emitter Emitter Definitions
 * @{
 *)

(**
 * The prototype of a write handler.
 *
 * The write handler is called when the emitter needs to flush the accumulated
 * characters to the output.  The handler should write @a size bytes of the
 * @a buffer to the output.
 *
 * @param[in,out]   data        A pointer to an application data specified by
 *                              yaml_emitter_set_output().
 * @param[in]       buffer      The buffer with bytes to be written.
 * @param[in]       size        The size of the buffer.
 *
 * @returns On success, the handler should return @c 1.  If the handler failed,
 * the returned value should be @c 0.
 *)

type TYamlWriteHandler = function(var data; buffer: PAnsiChar; size: Integer):
  Integer; cdecl;

(** The emitter states. *)
// yaml_emitter_state_t

(**
 * The emitter structure.
 *
 * All members are internal.  Manage the structure using the @c yaml_emitter_
 * family of functions.
 *)

type
  TYamlEmitterError = record

    (**
     * @name Error handling
     * @{
     *)

    (** Error type. *)
    error: TYamlErrorType;
    (** Error description. *)
    problem: PYamlChar;

    (**
     * @}
     *)

  end;
  PYamlEmitter = type Pointer;
  PYamlEmitterError = ^TYamlEmitterError;
var
  SizeOfTYamlEmitter: Integer; // initialized at runtime

(**
 * Initialize an emitter.
 *
 * This function creates a new emitter object.  An application is responsible
 * for destroying the object using the yaml_emitter_delete() function.
 *
 * @param[out]      emitter     An empty parser object.
 *
 * @returns @c 1 if the function succeeded, @c 0 on error.
 *)

function _yaml_emitter_initialize(emitter: PYamlEmitter): Integer; cdecl; external;

(**
 * Destroy an emitter.
 *
 * @param[in,out]   emitter     An emitter object.
 *)

procedure _yaml_emitter_delete(emitter: PYamlEmitter); cdecl; external;

(**
 * Set a string output.
 *
 * The emitter will write the output characters to the @a output buffer of the
 * size @a size.  The emitter will set @a size_written to the number of written
 * bytes.  If the buffer is smaller than required, the emitter produces the
 * YAML_WRITE_ERROR error.
 *
 * @param[in,out]   emitter         An emitter object.
 * @param[in]       output          An output buffer.
 * @param[in]       size            The buffer size.
 * @param[in]       size_written    The pointer to save the number of written
 *                                  bytes.
 *)

procedure _yaml_emitter_set_output_string(emitter: PYamlEmitter;
  output: PAnsiChar; size: Integer; var size_written: Integer); cdecl; external;

(**
 * Set a file output.
 *
 * @a file should be a file object open for writing.  The application is
 * responsible for closing the @a file.
 *
 * @param[in,out]   emitter     An emitter object.
 * @param[in]       file        An open file.
 *)

procedure _yaml_emitter_set_output_file(emitter: PYamlEmitter; file_: TStream); cdecl; external;

(**
 * Set a generic output handler.
 *
 * @param[in,out]   emitter     An emitter object.
 * @param[in]       handler     A write handler.
 * @param[in]       data        Any application data for passing to the write
 *                              handler.
 *)

procedure _yaml_emitter_set_output(emitter: PYamlEmitter;
  handler: TYamlWriteHandler; var data); cdecl; external;

(**
 * Set the output encoding.
 *
 * @param[in,out]   emitter     An emitter object.
 * @param[in]       encoding    The output encoding.
 *)

procedure _yaml_emitter_set_encoding(emitter: PYamlEmitter;
  encoding: TYamlEncoding); cdecl; external;

(**
 * Set if the output should be in the "canonical" format as in the YAML
 * specification.
 *
 * @param[in,out]   emitter     An emitter object.
 * @param[in]       canonical   If the output is canonical.
 *)

procedure _yaml_emitter_set_canonical(emitter: PYamlEmitter;
  canonical: Integer); cdecl; external;

(**
 * Set the intendation increment.
 *
 * @param[in,out]   emitter     An emitter object.
 * @param[in]       indent      The indentation increment (1 < . < 10).
 *)

procedure _yaml_emitter_set_indent(emitter: PYamlEmitter;
  indent: Integer); cdecl; external;

(**
 * Set the preferred line width. @c -1 means unlimited.
 *
 * @param[in,out]   emitter     An emitter object.
 * @param[in]       width       The preferred line width.
 *)

procedure _yaml_emitter_set_width(emitter: PYamlEmitter;
  width: Integer); cdecl; external;

(**
 * Set if unescaped non-ASCII characters are allowed.
 *
 * @param[in,out]   emitter     An emitter object.
 * @param[in]       unicode     If unescaped Unicode characters are allowed.
 *)

procedure _yaml_emitter_set_unicode(emitter: PYamlEmitter;
  unicode: Integer); cdecl; external;

(**
 * Set the preferred line break.
 *
 * @param[in,out]   emitter     An emitter object.
 * @param[in]       line_break  The preferred line break.
 *)

procedure _yaml_emitter_set_break(emitter: PYamlEmitter;
  line_break: TYamlBreak); cdecl; external;

(**
 * Emit an event.
 *
 * The event object may be generated using the yaml_parser_parse() function.
 * The emitter takes the responsibility for the event object and destroys its
 * content after it is emitted. The event object is destroyed even if the
 * function fails.
 *
 * @param[in,out]   emitter     An emitter object.
 * @param[in,out]   event       An event object.
 *
 * @returns @c 1 if the function succeeded, @c 0 on error.
 *)

function _yaml_emitter_emit(emitter: PYamlEmitter; event: PYamlEvent): Integer;
  cdecl; external;

(**
 * Start a YAML stream.
 *
 * This function should be used before yaml_emitter_dump() is called.
 *
 * @param[in,out]   emitter     An emitter object.
 *
 * @returns @c 1 if the function succeeded, @c 0 on error.
 *)

function _yaml_emitter_open(emitter: PYamlEmitter): Integer; cdecl; external;

(**
 * Finish a YAML stream.
 *
 * This function should be used after yaml_emitter_dump() is called.
 *
 * @param[in,out]   emitter     An emitter object.
 *
 * @returns @c 1 if the function succeeded, @c 0 on error.
 *)

function _yaml_emitter_close(emitter: PYamlEmitter): Integer; cdecl; external;

(**
 * Emit a YAML document.
 *
 * The documen object may be generated using the yaml_parser_load() function
 * or the yaml_document_initialize() function.  The emitter takes the
 * responsibility for the document object and destoys its content after
 * it is emitted. The document object is destroyedeven if the function fails.
 *
 * @param[in,out]   emitter     An emitter object.
 * @param[in,out]   document    A document object.
 *
 * @returns @c 1 if the function succeeded, @c 0 on error.
 *)

function _yaml_emitter_dump(emitter: PYamlEmitter; document: PYamlDocument):
  Integer; cdecl; external;

(**
 * Flush the accumulated characters to the output.
 *
 * @param[in,out]   emitter     An emitter object.
 *
 * @returns @c 1 if the function succeeded, @c 0 on error.
 *)

function _yaml_emitter_flush(emitter: PYamlEmitter): Integer; cdecl; external;

(** @} *)

implementation

uses
  Windows;

//-//-//-//-//-//-//-//-//

{$WARN UNSAFE_CODE OFF}

// C std library

function _memset(P: Pointer; B: Integer; count: Integer): pointer; cdecl;
begin
  Result := P;
  FillChar(P^, count, B);
end;

procedure _memcpy(dest, source: Pointer; count: Integer); cdecl;
begin
  Move(source^, dest^, count);
end;

procedure _memmove(dest, source: Pointer; count: Integer); cdecl;
begin
  Move(source^, dest^, count);
end;

function _malloc(Size: Integer): Pointer; cdecl;
begin
  try
    GetMem(Result, Size);
  except
    on EOutOfMemory do
      Result := nil;
  end;
  // OutputDebugString(PChar('Malloc: $' + IntToHex(Integer(Result), 8) + '(' + IntToStr(Size) + ')'));
end;

function _realloc(P: Pointer; Size: Integer): Pointer; cdecl;
begin
  Result := P;
  try
    ReallocMem(Result, Size);
  except
    on EOutOfMemory do
      Result := nil;
  end;
  // OutputDebugString(PChar('Realloc: $' + IntToHex(Integer(Result), 8) + '(' + IntToStr(Size) + ')'));
end;

procedure _free(Block: Pointer); cdecl;
begin
  FreeMem(Block);
  // OutputDebugString(PChar('Free: $' + IntToHex(Integer(Block), 8)));
end;

function _strdup(const s1 : PAnsiChar) : PAnsiChar; cdecl;
var
  L : Integer;
begin
  if not Assigned(s1) then
    Result := nil
  else
  begin
    L := StrLen(s1);
    GetMem(Result, L + 1);
    Move(s1^, Result^, L + 1);
    // OutputDebugString(PChar('Strdup: $' + IntToHex(Integer(Result), 8) + '(' + IntToStr(L + 1) + ')'));
  end;
end;

{$WARN UNSAFE_CODE ON}

function _strlen(const s : PAnsiChar) : Integer; cdecl;
begin
  Result := StrLen(s);
end;

function _sprintf(const s: PAnsiChar; const format: PAnsiChar): Integer; cdecl; varargs; external 'msvcrt.dll' name 'sprintf';

function _strcmp(const s1, s2: PAnsiChar): Integer; cdecl;
begin
  Result := StrComp(s1, s2);
end;

function _strncmp(const s1, s2: PAnsiChar; n: Integer): Integer; cdecl;
begin
  Result := StrLComp(s1, s2, n);
end;

function _memcmp(const s1, s2: Pointer; n: Integer): Integer; cdecl; external 'msvcrt.dll' name 'memcmp';

{$WARN UNSAFE_CAST OFF}

function _fread(ptr: Pointer; size, nelem: Integer; stream: Pointer): Integer; cdecl;
begin
  Result := TStream(stream).Read(ptr^, size * nelem) div size;
end;

function _fwrite(ptr: Pointer; size, nelem: Integer; stream: Pointer): Integer; cdecl;
begin
  try
    TStream(stream).WriteBuffer(ptr^, size * nelem);
    Result := size;
  except
    Result := 0;
  end;
end;

{$WARN UNSAFE_CAST ON}

procedure __assert(const __cond, __file: PAnsiChar; __line: Integer);
begin
  if Assigned(AssertErrorProc) then
    AssertErrorProc(__cond, __file, __line, Pointer(-1))
  else
    System.Error(reAssertionFailed);  // loses return address
end;

//-//-//-//-//-//-//-//-//-//

// yaml_private.h

function  _yaml_malloc(size: Integer): Pointer; cdecl; external;
function  _yaml_realloc(ptr: Pointer; size: Integer) : Pointer; cdecl; external;
procedure _yaml_free(ptr: Pointer); cdecl; external;
function  _yaml_strdup(s : PYamlChar) : PYamlChar; cdecl; external;

function  _yaml_parser_update_buffer(parser : PYamlParser; length : Integer) : Integer; cdecl; external;
function  _yaml_parser_fetch_more_tokens(parser : PYamlParser) : Integer; cdecl; external;

function  _yaml_string_extend(var start, ptr, end_: PYamlChar) : Integer; cdecl; external;
function  _yaml_string_join(var a_start, a_pointer, a_end, b_start, b_pointer, b_end: PYamlChar) : Integer; cdecl; external;

function _yaml_stack_extend(var start, top, end_ : Pointer) : Integer; cdecl; external;
function _yaml_queue_extend(var start, head, tail, end_ : Pointer): Integer; cdecl; external;

//-//-//-//-//-//-//-//-//-//

// delphibridge.c

procedure _yaml_delphibridge_getsizes(var yaml_parser_size,
  yaml_emitter_size: Integer); cdecl; external;

(* *)
{$L 'api.obj'}
{$L 'dumper.obj'}
{$L 'emitter.obj'}
{$L 'loader.obj'}
{$L 'parser.obj'}
{$L 'reader.obj'}
{$L 'scanner.obj'}
{$L 'writer.obj'}
{$L 'delphibridge.obj'}
(* *)

initialization
  _yaml_delphibridge_getsizes(SizeOfTYamlParser, SizeOfTYamlEmitter);
end.
