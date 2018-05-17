#!/bin/sh

## move Kata artifacts to /opt
echo "copying kata artifacts from /tmp to /opt"
cp -R /tmp/kata/* /opt/kata/

chmod +x /opt/kata/bin/*

cp /opt/kata/configuration.toml /usr/share/defaults/kata-containers/configuration.toml

## Configure CRIO to use Kata:
echo "Set manage_network_ns_lifecycle to true"
network_ns_flag="manage_network_ns_lifecycle"

# Check if flag is already defined in the CRI-O config file.
# If it is already defined, then just change the value to true,
# else, add the flag with the value.
if grep "$network_ns_flag" "$crio_config_file"; then
	 sed -i "s/^$network_ns_flag.*/$network_ns_flag = true/" "$crio_config_file"
else
	 sed -i "/\[crio.runtime\]/a$network_ns_flag = true" "$crio_config_file"
fi


### Configure CRIO to use Kata:
## Uncomment next line if you'd like to have default trust level for the cluster be "untrusted":
# sed -i 's/default_workload_trust = "trusted"/default_workload_trust = "untrusted"/' "$crio_config_file"

echo "Set Kata containers as default runtime in CRI-O for untrusted workloads"
 sed -i 's/runtime_untrusted_workload = ""/runtime_untrusted_workload = "\/opt\/kata\/bin\/kata-runtime"/' "$crio_config_file"

## Not sure the following is really needed:
service_path="/etc/systemd/system"
crio_service_file="${cidir}/data/crio.service"
echo "Install crio service (${crio_service_file})"
 install -m0444 "${crio_service_file}" "${service_path}"
echo "Reload systemd services"
 systemctl daemon-reload

### Restart CRIO:
