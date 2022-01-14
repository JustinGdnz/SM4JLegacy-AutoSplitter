state("SM4JLegacy")
{
    //uint data_pointer : "SM4JLegacy.exe", 0x443D84;
    uint data_size : "SM4JLegacy.exe", 0x445C64;
}

state("SM4JLegacy", "v2.0.5FIX")
{

    uint gm_room : "SM4JLegacy.exe", 0x6561E0;
    //uint gm_fps : "SM4JLegacy.exe", 0x6613B8;

    double mario_x : "SM4JLegacy.exe", 0x00443D44, 0x1C, 0xD0, 0x8, 0x80, 0xC8, 0x8, 0xB0;
    double mario_y : "SM4JLegacy.exe", 0x00443D44, 0x1C, 0xD0, 0x8, 0x80, 0xC8, 0x8, 0xB4;

    //double leveleditor_clear : "SM4JLegacy.exe", 0x00445C40, 0x60, 0x10, 0xB74, 0x10, 0x8, 0x200;
    double level_clear : "SM4JLegacy.exe", 0x00445C40, 0x60, 0x10, 0x880, 0x1F0;
    ulong game_time : "SM4JLegacy.exe", 0x658428;

}

startup
{
    settings.Add("basegame", false, "Modos de Juego");
    settings.Add("reset_on", true, "Reiniciar al salir del nivel");
        settings.SetToolTip("reset_on", "Cada que entres a un nivel y vuelvas al worldmap desde el menu de pausa el split se reiniciara automaticamente si NO completaste el nivel aun");

    settings.Add("Campaign", false, "Campañas Normales", "basegame");
        settings.SetToolTip("Campaign", "Campañas hechas con el motor del juego\n\nIncluye: (Operacion Rescate[Deshabilitado de momento], Niveles de la Beta)");
    
    settings.Add("Campaign_StartEnd", false, "Inicio a Fin", "Campaign");
        settings.SetToolTip("Campaign_StartEnd", "Un solo split, inicia al entrar al primer nivel y termina al completar el ultimo nivel de la camapaña");

    settings.Add("Campaign_SplitAll", false, "Splits", "Campaign");
        settings.SetToolTip("Campaign_SplitAll", "Al completar un nivel se hara split");


    settings.Add("Levels", false, "Niveles Individuales", "basegame");
        settings.SetToolTip("Levels", "Niveles hechos con el motor del juego\n\nIncluye: (Los niveles de las Campañas Normales)\nINCOMPATIBLE CON NIVELES HECHOS CON EL LEVEL EDITOR, NIVELES DE LOS DEMAS MODOS SE IRAN AÑADIENDO EVENTUALMENTE");

    settings.Add("Levels_NoSplits", false, "No Splits", "Levels");
        settings.SetToolTip("Levels_NoSplits", "Inicia al entrar al nivel y termina al completarlo");

    settings.Add("Levels_Splits", false, "Splits", "Levels");
        settings.SetToolTip("Levels_Splits", "Cada transicion de room se hara un split... no se, para aquellos que les guste decorar sus splits");
    

    settings.Add("TerrorMansion", false, "Terror Mansion", "basegame");
        settings.SetToolTip("TerrorMansion", "[WIP]");


    settings.Add("Bosses", false, "Modo Jefes", "basegame");
        settings.SetToolTip("Bosses", "[WIP]");


    settings.Add("Races", false, "Modo Carrera", "basegame");
        settings.SetToolTip("Races", "[WIP]");
}

init
{
    if (current.data_size == 0x01C1C2D5)
        version = "v2.0.5FIX";
    else
        print("Not a valid version");

    vars.worldmap = 0;
    vars.last_level = 0;
    vars.completed = false;
}

start
{
    if (settings["Campaign"])
    {
        if (old.gm_room != current.gm_room)
        {
            if (old.gm_room == 152 && current.gm_room == 155)
            {
                vars.worldmap = 152;
                vars.last_level = 173;
                return true;
            }
//            else if (old.gm_room == 153 && current.gm_room == 225)
//            {
//                vars.worldmap = 153;
//                vars.last_level = 0;
//                return true;
//            }
        }
    }

    if (settings["Levels"])
    {
        if (old.gm_room != current.gm_room)
        {
            if (old.gm_room == 152 || old.gm_room == 153)
            {
                vars.worldmap = old.gm_room;
                return true;
            }
        }
    }
}

split
{
    if (settings["Campaign"])
    {
        if (settings["Campaign_SplitAll"])
            return old.level_clear < 1 && current.level_clear > 0;
        if (settings["Campaign_StartEnd"])
            return current.gm_room == vars.last_level && current.level_clear > 0;
    }

    if (settings["Levels"])
    {
        if (settings["Levels_NoSplits"])
            return old.level_clear < 1 && current.level_clear > 0;
        if (settings["Levels_Splits"])
            return (old.gm_room != current.gm_room && current.gm_room != vars.worldmap) || (old.level_clear < 1 && current.level_clear > 0);
    }
}

reset
{
    if (current.gm_room == 0)
        return true;
    if (settings["reset_on"])
    {    
        if (settings["Campaign"] || settings["Levels"])
        {
            return old.gm_room != current.gm_room && current.gm_room == vars.worldmap && current.level_clear < 1;
        }
    }
}