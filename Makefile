# ====================================================
# Variables
# ====================================================
APP_NAME := lazy-ubuntu
mode ?= normal

ifeq ($(filter --gui,$(MAKECMDGOALS)),--gui)
  DOCKER_COMPOSE := deployments/ubuntu/gui/docker-compose.yml
else
  DOCKER_COMPOSE := \
    $(if $(filter vpn,$(mode)), \
         deployments/vpn/docker-compose.yml, \
         deployments/ubuntu/server/docker-compose.yml)
endif

DATA_DIR := ./data
CONFIG_DIR := ./config

VPN_SERVER := openvpn

# ====================================================
# Docker Compose targets
# ====================================================
.PHONY: start stop reset listconfigs

start:
	docker-compose -f $(DOCKER_COMPOSE) -p $(APP_NAME) --compatibility up -d

stop:
	docker-compose -f $(DOCKER_COMPOSE) -p $(APP_NAME) down

reset:
	@CONTAINERS=$$(docker ps -a -q); \
	if [ -n "$$CONTAINERS" ]; then \
		echo "Stopping containers..."; \
		docker stop $$CONTAINERS; \
	else \
		echo "No containers to stop."; \
	fi
	docker network prune -f
	docker container prune -f
	docker volume prune -a -f
	docker image prune -a -f

listconfigs:
	docker exec openvpn ./listconfigs.sh

# ====================================================
# VPN management targets
# ====================================================
.PHONY: apply-vpn-config apply-push-routes verify-vpn-config

# Apply VPN config to a container (SERVER=<name_or_ip>)
apply-vpn-config:
ifndef SERVER
	$(error SERVER is not set. Usage: make apply-vpn-config SERVER=<name_or_ip>)
endif
	@echo "Using server: $(SERVER)"
	@mkdir -p $(DATA_DIR)
	@PROFILE_ID=$$(docker exec $(VPN_SERVER) ./listconfigs.sh); \
	echo "Profile ID: $$PROFILE_ID"; \
	docker cp $(VPN_SERVER):/opt/Dockovpn_data/clients/$$PROFILE_ID/client.ovpn $(DATA_DIR)/client.ovpn; \
	docker cp $(DATA_DIR)/client.ovpn $(SERVER):/; \
	docker exec -d $(SERVER) bash -c "\
		apt-get update && \
		apt-get install -y openvpn && \
		openvpn --config /client.ovpn --daemon \
	"

# Apply push-routes to VPN server (VPN_SERVER=<name_or_ip>)
apply-push-routes:
	@echo "Using VPN server: $(VPN_SERVER)"
	@subnet=$${PRIVATE_NETWORK_SUBNET}; \
	mask="255.255.0.0"; \
	docker exec $(VPN_SERVER) bash -c "echo 'push \"route $$subnet $$mask\";' >> /opt/Dockovpn/config/server.conf"

# Verify VPN config inside container (SERVER=<name_or_ip>)
verify-vpn-config:
ifndef SERVER
	$(error SERVER is not set. Usage: make verify-vpn-config SERVER=<name_or_ip>)
endif
	@echo "Using server: $(SERVER)"
	docker exec $(SERVER) bash -c '\
		ip addr show tun0; \
		ip route show \
	' | column -t
