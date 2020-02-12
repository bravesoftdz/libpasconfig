unit pasconfigtestcase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, libpasconfig, pasconfig;

type

  { TLibConfigTest }

  TLibConfigTest = class(TTestCase)
  private
    FConfig : config_t;
  published
    procedure TestCreateConfig;
    procedure TestCreateConfigArray;
    procedure TestCreateConfigFile;
    procedure TestCreateConfigReadWriteFile;
  end;

  { TConfigTest }

  TConfigTest = class(TTestCase)
  private
    FConfig : TConfig;
  published
    procedure TestCreateConfig;
    procedure TestCreateConfigArray;
    procedure TestCreateConfigList;
  end;

implementation

{ TConfigTest }
{ Create config file, write and read parameters }
procedure TConfigTest.TestCreateConfig;
var
  Option : TConfig.TOptionReader;
  IntValue : Integer;
  Int64Value : Int64;
  StringValue : String;
  BooleanValue : Boolean;
begin
  FConfig := TConfig.Create;

  with FConfig.CreateSection['test'] do
  begin
    SetInteger['option1'] := 456;
    SetInt64['option2'] := 123456;
    SetFloat['option3'] := 0.001;
    SetString['option4'] := 'test value';
    SetBoolean['option5'] := True;
  end;

  Option := FConfig.Value['test.option1'];
  IntValue := Option.AsInteger;
  AssertTrue('Config eleemnt ''test.option1'' has incorrect type',
    Option.OptionType = TYPE_INTEGER);
  AssertTrue('Config element ''test.option1'' has incorrect name',
    Option.OptionName = 'option1');
  AssertTrue('Config element ''test.option1'' is incorrect value',
    IntValue = 456);

  Option := FConfig.Value['test.option2'];
  Int64Value := Option.AsInt64;
  AssertTrue('Config eleemnt ''test.option2'' has incorrect type',
    Option.OptionType = TYPE_INT64);
  AssertTrue('Config element ''test.option2'' has incorrect name',
    Option.OptionName = 'option2');
  AssertTrue('Config element ''test.option2'' is incorrect value',
    Int64Value = 123456);

  Option := FConfig.Value['test.option4'];
  StringValue := Option.AsString;
  AssertTrue('Config eleemnt ''test.option4'' has incorrect type',
    Option.OptionType = TYPE_STRING);
  AssertTrue('Config element ''test.option4'' has incorrect name',
    Option.OptionName = 'option4');
  AssertTrue('Config element ''test.option4'' is incorrect value',
    StringValue = 'test value');

  Option := FConfig.Value['test.option5'];
  BooleanValue := Option.AsBoolean;
  AssertTrue('Config eleemnt ''test.option5'' has incorrect type',
    Option.OptionType = TYPE_BOOLEAN);
  AssertTrue('Config element ''test.option5'' has incorrect name',
    Option.OptionName = 'option5');
  AssertTrue('Config element ''test.option5'' is incorrect value',
    BooleanValue = True);

  FreeAndNil(FConfig);
end;

{ Create config, write/read array }
procedure TConfigTest.TestCreateConfigArray;
var
  Option : TConfig.TOptionReader;
  IntValue : Integer;
  i : Integer;
begin
  FConfig := TConfig.Create;

  with FConfig.CreateSection['test'].CreateArray['test_array'] do
  begin
    for i := 1 to 10 do
      SetInteger[''] := i;
  end;

  i := 1;
  for Option in FConfig.Value['test.test_array'].AsArray do
  begin
    IntValue := Option.AsInteger;
    AssertTrue('Config ''array.test_array'' array element has incorrect type',
      Option.OptionType = TYPE_INTEGER);
    AssertTrue('Config ''array.test_array'' array element is incorrect value',
      IntValue = i);
    Inc(i);
  end;

  FreeAndNil(FConfig);
end;

{ Create config, write/read list }
procedure TConfigTest.TestCreateConfigList;
var
  Option : TConfig.TOptionReader;
  IntValue : Integer;
  StringValue : String;
  i : Integer;
begin
  FConfig := TConfig.Create;

  with FConfig.CreateSection['test'].CreateList['test_list'] do
  begin
    for i := 1 to 10 do
    begin
      with CreateSection['option' + IntToStr(i)] do
      begin
        SetString['string_value'] := 'Value' + IntToStr(i);
        SetInteger['integer_value'] := i + 8;
      end;
    end;
  end;

  i := 1;
  for Option in FConfig.Value['test.test_list'].AsList do
  begin
    StringValue := Option.Value['string_value'].AsString;
    AssertTrue('Config element ''option' + IntToStr(i) + '.string_value'' ' +
      'is incorrect value', StringValue = 'Value' + IntToStr(i));
    IntValue := Option.Value['integer_value'].AsInteger;
    AssertTrue('Config element ''option' + IntToStr(i) + '.integer_value'' ' +
      'is incorrect value', IntValue = i + 8);
    Inc(i);
  end;

  FreeAndNil(FConfig);
end;

{ TLibConfigTest }

{ Create new config and setup test options values }
procedure TLibConfigTest.TestCreateConfig;
var
  root, setting, group : pconfig_setting_t;
begin
  config_init(@FConfig);
  root := config_root_setting(@FConfig);
  AssertTrue('Root config element is nil', root <> nil);

  group := config_setting_add(root, 'test', CONFIG_TYPE_GROUP);
  AssertTrue('Group config element is nil', group <> nil);

  setting := config_setting_add(group, 'option1', CONFIG_TYPE_INT);
  AssertTrue('Added ''option1'' option type ''INT'' is nil', setting <> nil);
  config_setting_set_int(setting, 456);

  setting := config_setting_add(group, 'option2', CONFIG_TYPE_INT64);
  AssertTrue('Added ''option2'' option type ''INT64'' is nil', setting <> nil);
  config_setting_set_int(setting, 123456);

  setting := config_setting_add(group, 'option3', CONFIG_TYPE_FLOAT);
  AssertTrue('Added ''option3'' option type ''FLOAT'' is nil', setting <> nil);
  config_setting_set_float(setting, 0.001);

  setting := config_setting_add(group, 'option4', CONFIG_TYPE_STRING);
  AssertTrue('Added ''option4'' option type ''STRING'' is nil', setting <> nil);
  config_setting_set_string(setting, PChar('test value'));

  setting := config_setting_add(group, 'option5', CONFIG_TYPE_BOOL);
  AssertTrue('Added ''option5'' option type ''BOOL'' is nil', setting <> nil);
  config_setting_set_bool(setting, 1);

  config_destroy(@FConfig);
end;

{ Create config and add array option }
procedure TLibConfigTest.TestCreateConfigArray;
var
  root, arr, setting, group : pconfig_setting_t;
  i : Integer;
begin
  config_init(@FConfig);
  root := config_root_setting(@FConfig);
  AssertTrue('Root config element is nil', root <> nil);

  group := config_setting_add(root, 'test', CONFIG_TYPE_GROUP);
  AssertTrue('Group config element is nil', group <> nil);

  arr := config_setting_add(group, 'array_options', CONFIG_TYPE_ARRAY);
  AssertTrue('Added ''array_options'' option type ''ARRAY'' is nil', arr <>
    nil);

  for i := 1 to 10 do
  begin
    setting := config_setting_add(arr, nil, CONFIG_TYPE_INT);
    AssertTrue('Added new array element is nil', setting <> nil);
    config_setting_set_int(setting, i);
  end;

  config_destroy(@FConfig);
end;

{ Create config, add some test values and write to file }
procedure TLibConfigTest.TestCreateConfigFile;
var
  root, setting, group : pconfig_setting_t;
  write_result : Integer;
begin
  config_init(@FConfig);
  root := config_root_setting(@FConfig);
  AssertTrue('Root config element is nil', root <> nil);

  group := config_setting_add(root, 'test', CONFIG_TYPE_GROUP);
  AssertTrue('Group config element is nil', group <> nil);

  setting := config_setting_add(group, 'option1', CONFIG_TYPE_STRING);
  AssertTrue('Added ''option1'' option type ''STRING'' is nil', setting <> nil);
  config_setting_set_string(setting, PChar('option value'));

  setting := config_setting_add(group, 'option2', CONFIG_TYPE_INT);
  AssertTrue('Added ''option2'' option type ''INT'' is nil', setting <> nil);
  config_setting_set_int(setting, -5);

  write_result := config_write_file(@FConfig, 'test.cfg');
  AssertTrue('Write config file is error', write_result <> 0);
  AssertTrue('Config file is not exists', FileExists('test.cfg'));

  DeleteFile('test.cfg');
  config_destroy(@FConfig);
end;

{ Create config, add some test values, write to file and after try to open file
  and read the tests values }
procedure TLibConfigTest.TestCreateConfigReadWriteFile;
var
  root, setting, group : pconfig_setting_t;
  write_result, read_result : Integer;
  Value : PChar;
begin
  config_init(@FConfig);
  root := config_root_setting(@FConfig);
  AssertTrue('Root config element is nil', root <> nil);

  group := config_setting_add(root, 'Group', CONFIG_TYPE_GROUP);
  AssertTrue('Config group element is nil', group <> nil);

  setting := config_setting_add(group, 'option1', CONFIG_TYPE_STRING);
  AssertTrue('Added ''option1'' option type ''STRING'' is nil', setting <> nil);
  config_setting_set_string(setting, PChar('test value'));

  setting := config_setting_add(group, 'option2', CONFIG_TYPE_INT);
  AssertTrue('Added ''option2'' option type ''INT'' is nil', setting <> nil);
  config_setting_set_int(setting, 1001);

  write_result := config_write_file(@FConfig, 'test.cfg');
  AssertTrue('Write config file is error', write_result <> 0);
  AssertTrue('Config file is not exists', FileExists('test.cfg'));

  config_destroy(@FConfig);
  config_init(@FConfig);

  read_result := config_read_file(@FConfig, 'test.cfg');
  AssertTrue('Read config file is error', read_result <> 0);

  config_lookup_string(@FConfig, 'Group.option1', @Value);
  AssertTrue(' ''Group.option1'' config option is not find', Value <> nil);
  AssertTrue('Option value is not corect', Value = 'test value');

  DeleteFile('test.cfg');
  config_destroy(@FConfig);
end;

initialization
  RegisterTest(TLibConfigTest);
  RegisterTest(TConfigTest);
end.

