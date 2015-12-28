///udphp_clientNetworking(client)

/*
**  Description:
**      This script will do two things:
**          * Check if the master server sends back server information (the port)
**          * Check if server connection is done.
**      Requirement: Configured client (udphp_config and udphp_createClient)
**      This should be used in the networking event of the client object.
**  
**  Usage:
**      udphp_clientNetworking(client)
**
**  Arguments:
**      client     real    id of the client to check
**
**  Returns:
**      <nothing>
**
*/
var client = argument0;
/// CHECK IF CLIENT IS RUNNING (we can use any client-releated variable for that; we assume they don't get changed from outside)
if (!instance_exists(client)) {
    udphp_handleerror(udphp_dbglvl.DEBUG, udphp_dbgtarget.CLIENT, client, "Client not found");
}

//Networking related variables
var in_id = ds_map_find_value(async_load, "id");
var in_buff = ds_map_find_value(async_load, "buffer");
var in_ip = ds_map_find_value(async_load, "ip");

//Only continue if this is for the client
if (in_id != client.udp_socket and in_id != client.tcp_socket) exit;

///SCENARIO 1: Master Server sent an answer
if (in_ip == global.udphp_master) {
    udphp_handleerror(udphp_dbglvl.DEBUG, udphp_dbgtarget.CLIENT, client, "Got message from master server");
    //Check command
    var com = buffer_read(in_buff, buffer_s8 );
    switch com {
        case udphp_packet.MASTER:
            //master server sent port and ip! Set IP and port and set directconnect to true
            //client will now connect to server
            udphp_handleerror(udphp_dbglvl.DEBUG, udphp_dbgtarget.CLIENT, client, "Server found!");
            client.server_ip = buffer_read(in_buff, buffer_string )
            client.server_port = real(buffer_read(in_buff, buffer_string ));
            client.directconnect = true;
        break;
        case udphp_packet.MASTER_NOTFOUND:
            //server not found. Try to connect directly.
            udphp_handleerror(udphp_dbglvl.DEBUG, udphp_dbgtarget.CLIENT, client, "Remote server not connected to master server, try a direct connect.");
            client.directconnect = true;
        break;
        default:
            udphp_handleerror(udphp_dbglvl.DEBUG, udphp_dbgtarget.CLIENT, client, "Unknown message from master server. ("+string(com)+")");
        break;
    }
///SCENARIO 2: Connected to server
} else if (!udphp_clientIsConnected(client) /* * Sadly in_ip is empty if the server contacts us * && in_ip == ds_map_find_value(global.udphp_clients_serverip,client)*/) {
    udphp_handleerror(udphp_dbglvl.DEBUG, udphp_dbgtarget.CLIENT, client, "Got message from server");
    switch buffer_read(in_buff, buffer_s8 ) {
        case udphp_packet.SERVWELCOME:
            udphp_handleerror(udphp_dbglvl.DEBUG, udphp_dbgtarget.CLIENT, client, "CONNECTED TO SERVER!");
            //We can kill the socket to the master server now
            network_destroy(client.tcp_socket);
            client.connected = true;
        break;
    }
} else {
     //SCENARIO 2,5: Check if data was recieved.
     switch buffer_read(in_buff, buffer_s8 ) {
        case udphp_packet.DATA:
             global.udphp_tmp_data1 = buffer_read(in_buff, buffer_string );
             global.udphp_tmp_data2 = buffer_read(in_buff, buffer_string );
             global.udphp_tmp_data3 = buffer_read(in_buff, buffer_string );
             global.udphp_tmp_data4 = buffer_read(in_buff, buffer_string );
             global.udphp_tmp_data5 = buffer_read(in_buff, buffer_string );
             global.udphp_tmp_data6 = buffer_read(in_buff, buffer_string );
             global.udphp_tmp_data7 = buffer_read(in_buff, buffer_string );
             global.udphp_tmp_data8 = buffer_read(in_buff, buffer_string );
             udphp_handleerror(udphp_dbglvl.DEBUG, udphp_dbgtarget.CLIENT, client, "Got data from server. Check (data1): "+global.udphp_tmp_data1);
             
     }
     //After that we need to reset the buffer for future use
     buffer_seek(in_buff, buffer_seek_start, 0);
}
///SCENARIO X: Packet has nothing to do with GMnet PUNCH, ignore
