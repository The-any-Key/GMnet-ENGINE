//Initializes the DLL
//processDLL_init(filename)
global.ProcessDLLName = argument0;
global.ProcessLaunch = external_define(argument0,"ProcessLaunch",dll_stdcall,ty_real,3,ty_string,ty_string,ty_string);
global.ProgramLaunch = external_define(argument0,"ProgramLaunch",dll_stdcall,ty_real,4,ty_string,ty_string,ty_string,ty_real);