# ====================================================
# Variables
# ====================================================
APP_NAME := lazy-ubuntu
mode ?= normal
gui ?= 0

ifeq ($(gui),1)
  DOCKER_COMPOSE := deployments/ubuntu/gui/docker-compose.yml
else ifeq ($(mode),vpn)
  DOCKER_COMPOSE := deployments/vpn/docker-compose.yml
else
  DOCKER_COMPOSE := deployments/ubuntu/server/docker-compose.yml
endif

DATA_DIR := ./data
CONFIG_DIR := ./config

VPN_SERVER := openvpn

# Colors
CYAN   := \033[36m
GREEN  := \033[32m
RED    := \033[31m
YELLOW := \033[33m
RESET  := \033[0m
BOLD   := \033[1m
CHECK  := ✅
CROSS  := ❌

# ====================================================
# Helper Macros
# ====================================================
define run
	@echo "$(YELLOW)▶ $(1)$(RESET)"
	@$(2) && echo "$(GREEN)$(CHECK) $(1) completed.$(RESET)" || echo "$(RED)$(CROSS) $(1) failed.$(RESET)"
endef

# ====================================================
# Docker Compose targets
# ====================================================
.PHONY: start stop reset listconfigs

start: ## Start lab (normal / vpn / gui)
	$(call run,"Starting lab",docker-compose -f $(DOCKER_COMPOSE) -p $(APP_NAME) --compatibility up -d)

stop: ## Stop current lab
	$(call run,"Stopping lab",docker-compose -f $(DOCKER_COMPOSE) -p $(APP_NAME) down)

reset: ## Reset lab (remove containers, networks, volumes, images)
	$(call run,"Stopping all containers",bash -c '\
		CONTAINERS=$$(docker ps -a -q); \
		if [ -n "$$CONTAINERS" ]; then \
			docker stop $$CONTAINERS; \
		else \
			echo "No containers to stop."; \
		fi')
	$(call run,"Pruning networks",docker network prune -f)
	$(call run,"Pruning containers",docker container prune -f)
	$(call run,"Pruning volumes",docker volume prune -a -f)
	$(call run,"Pruning images",docker image prune -a -f)

listconfigs: ## List OpenVPN profiles on server
	$(call run,"Listing VPN configs",docker exec $(VPN_SERVER) ./listconfigs.sh)

# ====================================================
# VPN management targets
# ====================================================
.PHONY: apply-vpn-config apply-push-routes verify-vpn-config

apply-vpn-config: ## Apply VPN config to a container (SERVER=<name>)
ifndef SERVER
	$(error SERVER is not set. Usage: make apply-vpn-config SERVER=<name_or_ip>)
endif
	$(call run,"Applying VPN config",bash -c '\
		echo "Using server: $(SERVER)"; \
		mkdir -p $(DATA_DIR); \
		PROFILE_ID=$$(docker exec $(VPN_SERVER) ./listconfigs.sh); \
		echo "Profile ID: $$PROFILE_ID"; \
		docker cp $(VPN_SERVER):/opt/Dockovpn_data/clients/$$PROFILE_ID/client.ovpn $(DATA_DIR)/client.ovpn; \
		docker cp $(DATA_DIR)/client.ovpn $(SERVER):/; \
		docker exec -d $(SERVER) bash -c "\
			apt-get update && \
			apt-get install -y openvpn && \
			openvpn --config /client.ovpn --daemon" \
	')

apply-push-routes: ## Apply push routes to OpenVPN server
	$(call run,"Applying push routes",bash -c '\
		echo "Using VPN server: $(VPN_SERVER)"; \
		subnet=$${PRIVATE_NETWORK_SUBNET}; \
		mask="255.255.0.0"; \
		docker exec $(VPN_SERVER) bash -c "echo \'push \"route $$subnet $$mask\";\' >> /opt/Dockovpn/config/server.conf" \
	')

verify-vpn-config: ## Verify VPN interface & routes inside container (SERVER=<name>)
ifndef SERVER
	$(error SERVER is not set. Usage: make verify-vpn-config SERVER=<name_or_ip>)
endif
	$(call run,"Verifying VPN config",docker exec $(SERVER) bash -c '\
		ip addr show tun0; \
		ip route show \
	' | column -t)

# ====================================================
# Help
# ====================================================
.PHONY: help
help: ## Show this help
	@echo ""
	@echo "$(BOLD)$(CYAN)Lazy Ubuntu - Available commands$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""
