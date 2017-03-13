/*  SM Jailed Reasons
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <sdktools>

#pragma semicolon 1


#define VERSION "v1.0"


new g_Dias[MAXPLAYERS+1];

new bool:muerto[MAXPLAYERS+1] = {false, ...};

new g_phraseCount;
new String:g_Phrases[256][192];



public Plugin:myinfo =
{
    name = "SM Jailed Reasons",
    author = "Franc1sco steam: franug",
    description = "shows the reasons for incarceration",
    version = VERSION,
    url = "http://steamcommunity.com/id/franug"
};

public OnPluginStart()
{
    
    // ======================================================================
    
    HookEvent("round_end", Event_RoundEnd);
    HookEvent("player_spawn", Event_PlayerSpawn);
    HookEvent("player_death", PlayerDeath);

    g_phraseCount = BuildPhrases();
    
    // ======================================================================
    
    // ======================================================================
    
    // ======================================================================
    
    CreateConVar("sm_jailreasons_version", VERSION, "version", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
}

public OnClientPostAdminCheck(client)
{
    g_Dias[client] = 1;

    muerto[client] = false;
}

public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
   new client = GetClientOfUserId(GetEventInt(event, "userid"));

   muerto[client] = true;
}

public Action:Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
  for (new i = 1; i < GetMaxClients(); i++)
  {
	if (IsClientInGame(i))
	{ 
              muerto[i] = false;
              g_Dias[i] += 1;
	}
  }
}
 

public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
 new client = GetClientOfUserId(GetEventInt(event, "userid"));

 if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) && (GetClientTeam(client) == 2) )
 {

    if (!muerto[client])
    {

                 //new frase;

                 decl String:frase[256];

                 Format(frase, 256, "%s",g_Phrases[GetRandomInt(0,(g_phraseCount -1 ))]);

                 PrintCenterText(client, "Day %i %s", g_Dias[client],frase);
                 PrintToChat(client, "\x05Day %i %s", g_Dias[client],frase); 
                 PrintHintText(client, "Day %i %s", g_Dias[client],frase);  

     }
  }
}

BuildPhrases()
{
	decl String:imFile[PLATFORM_MAX_PATH];
	decl String:line[192];
	new i = 0;
	new totalLines = 0;
	
	BuildPath(Path_SM, imFile, sizeof(imFile), "configs/franug_days_jail.ini");
	
	new Handle:file = OpenFile(imFile, "rt");
	
	if(file != INVALID_HANDLE)
	{
		while (!IsEndOfFile(file))
		{
			if (!ReadFileLine(file, line, sizeof(line)))
			{
				break;
			}
			
			TrimString(line);
			if( strlen(line) > 0 )
			{
				FormatEx(g_Phrases[i],192, "%s", line);
				totalLines++;
			}
			
			i++;
			
			//check for max no. of entries
			if( i >= sizeof(g_Phrases) )
			{
				LogError("Attempted to add more than the maximum allowed phrases from file");
				break;
			}
		}
				
		CloseHandle(file);
	}
	else
	{
		LogError("[SM] no file found for phrases (configs/franug_days_jail.ini)");
	}
	
	return totalLines;
}