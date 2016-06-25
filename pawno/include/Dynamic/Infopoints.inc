#define MAX_INFOPOINTS 20
#define IP_Distance 5.0

enum eInfopoints{
	ipID,
	Float:ipX,
	Float:ipY,
	Float:ipZ,
	ipText[50],
}

new iamount = 0;

new InfopointData[MAX_INFOPOINTS][eInfopoints];

stock InfopointsOnGameModeInit()
{
	new ipi, ipresult[200];
	mysql_query("SELECT `id`, `x`, `y`, `z`, `text` FROM `infopoints`;");
	mysql_store_result();
	new infoname[50];
	while(mysql_fetch_row_format(ipresult)) 
	{
		sscanf(ipresult,"p<|>e<ifffs[50]>",InfopointData[ipi]);
		ipi++;
		iamount ++;
	}
    mysql_free_result();
	
	for(new ipI = 0; ipI < iamount; ipI++)
	{
		if(InfopointData[ipI][ipID] > 0)
		{
			format(infoname, sizeof(infoname), "%s", InfopointData[ipI][ipText]);
			CreatePickup(1239, 1, InfopointData[ipI][ipX], InfopointData[ipI][ipY], InfopointData[ipI][ipZ], -1); 
			CreateDynamic3DTextLabel(infoname, cEnter, InfopointData[ipI][ipX], InfopointData[ipI][ipY], InfopointData[ipI][ipZ], IP_Distance);		
		}
	}
	
	printf("[START] Infopoints geladen. [%d]", iamount);
}