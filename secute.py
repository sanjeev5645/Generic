 
 from ssh_connect_handler import SSHConnectHandler
 
 def execute_commands(self):
    ssh_connect_handler = None
    ssh_connect_handler = SSHConnectHandler(ip=self.credentials.ip_or_fqdn,
                                                    username=self.credentials.username,
                                                    password=self.credentials.password,
                                                    device_type=self.credentials.device_type,
                                                    port=self.credentials.port)
    command_output_dict = {}
    workload = ['switch':'show system','routes':'show ip routes','showSwitchPorts':'show interfaces','showRouterInterfaces':'show ip interface','vrfs':'show vrf']
    for COMMAND_KEY in workload:
        command_result = ssh_connect_handler.execute_command(workload[COMMAND_KEY])
        command_output_dict[workload[COMMAND_KEY]] = command_result

    ssh_connect_handler.close_connection()
    print(command_output_dict)

if __name__ == "__main__":
    execute_commands()