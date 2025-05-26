.PHONY: install uninstall check-deps

# Основные переменные
SCRIPT_NAME := exe-icon-extract.sh
DESKTOP_FILE := exe-icon-extract.desktop
BIN_DIR := $(HOME)/.local/bin
NAUTILUS_SCRIPTS_DIR := $(HOME)/.local/share/nautilus/scripts
KDE_SERVICEMENUS_DIR := $(HOME)/.local/share/kio/servicemenus

install: check-deps
	@echo "Установка скрипта для извлечения иконок..."
	
	# Создаем директории, если их нет
	@mkdir -p $(BIN_DIR)
	@install -Dm755 $(SCRIPT_NAME) $(BIN_DIR)/$(SCRIPT_NAME)
	
	# Определяем DE и устанавливаем соответствующие файлы
	@if [ -n "$$(pgrep gnome-session)" ]; then \
		echo "Обнаружен GNOME, устанавливаем для Nautilus..."; \
		mkdir -p $(NAUTILUS_SCRIPTS_DIR); \
		ln -sf $(BIN_DIR)/$(SCRIPT_NAME) "$(NAUTILUS_SCRIPTS_DIR)/Извлечь иконку"; \
		echo "Перезагружаем Nautilus..."; \
		nautilus -q >/dev/null 2>&1 || true; \
	elif [ -n "$$(pgrep plasmashell)" ]; then \
		echo "Обнаружен KDE, устанавливаем сервисное меню..."; \
		mkdir -p $(KDE_SERVICEMENUS_DIR); \
		install -Dm644 $(DESKTOP_FILE) $(KDE_SERVICEMENUS_DIR)/$(DESKTOP_FILE); \
		echo "Обновляем кэш KDE..."; \
		kbuildsycoca6 >/dev/null 2>&1 || true; \
	else \
		echo "Не удалось определить DE (GNOME/KDE)"; \
		exit 1; \
	fi
	@echo "Установка завершена успешно!"

check-deps:
	@if ! command -v wrestool >/dev/null 2>&1; then \
		echo "Устанавливаем icoutils (требуются права root)..."; \
		su -c 'apt-get install -y icoutils'; \
	fi

uninstall:
	@echo "Удаление скрипта..."
	@rm -f $(BIN_DIR)/$(SCRIPT_NAME)
	@if [ -n "$$(pgrep gnome-session)" ]; then \
		rm -f "$(NAUTILUS_SCRIPTS_DIR)/Извлечь иконку"; \
		nautilus -q >/dev/null 2>&1 || true; \
	elif [ -n "$$(pgrep plasmashell)" ]; then \
		rm -f $(KDE_SERVICEMENUS_DIR)/$(DESKTOP_FILE); \
		kbuildsycoca6 >/dev/null 2>&1 || true; \
	fi
	@echo "Удаление завершено"
