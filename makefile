# Makefile для установки/удаления скрипта извлечения иконок

.PHONY: install uninstall check-icoutils install-gnome install-kde detect-de install-script uninstall-gnome uninstall-kde

INSTALL_DIR = $(HOME)/.local/bin
ICON_SCRIPT = exe-icon-extract.sh
DESKTOP_FILE = exe-icon-extract.desktop
KDE_SERVICEMENU_DIR = $(HOME)/.local/share/kio/servicemenus
NAUTILUS_SCRIPTS_DIR = $(HOME)/.local/share/nautilus/scripts

install:
	@$(MAKE) --no-print-directory check-icoutils
	@$(MAKE) --no-print-directory detect-de
	@$(MAKE) --no-print-directory install-script
	@echo "Установка завершена успешно."

uninstall:
	@$(MAKE) --no-print-directory detect-de
	@rm -f "$(INSTALL_DIR)/$(ICON_SCRIPT)" >/dev/null 2>&1
	@echo "Скрипт удалён из $(INSTALL_DIR)"
	@$(MAKE) --no-print-directory uninstall-gnome
	@$(MAKE) --no-print-directory uninstall-kde
	@echo "Удаление завершено"

uninstall-gnome:
	@if [ -f "$(NAUTILUS_SCRIPTS_DIR)/Извлечь иконку" ]; then \
		rm -f "$(NAUTILUS_SCRIPTS_DIR)/Извлечь иконку"; \
		echo "Удалена ссылка из Nautilus"; \
		pkill nautilus >/dev/null 2>&1 || true; \
	fi

uninstall-kde:
	@if [ -f "$(KDE_SERVICEMENU_DIR)/$(DESKTOP_FILE)" ]; then \
		rm -f "$(KDE_SERVICEMENU_DIR)/$(DESKTOP_FILE)"; \
		echo "Удалён desktop-файл из KDE servicemenus"; \
		kbuildsycoca6 >/dev/null 2>&1 || true; \
	fi

check-icoutils:
	@if ! command -v wrestool >/dev/null 2>&1; then \
		echo "icoutils не установлен, пытаюсь установить..."; \
		if [ -x "$(command -v su)" ]; then \
			su -c 'apt-get install -y icoutils >/dev/null 2>&1' && echo "icoutils успешно установлен."; \
		else \
			echo "Ошибка: не удалось выполнить установку icoutils (su не доступен)"; \
			exit 1; \
		fi \
	else \
		echo "icoutils уже установлен, продолжаю установку..."; \
	fi

detect-de:
	@if [ -n "$$(echo $$XDG_CURRENT_DESKTOP | grep -i gnome)" ] || [ -n "$$(pgrep gnome-session)" ]; then \
		export DE_TYPE=gnome; \
	elif [ -n "$$(echo $$XDG_CURRENT_DESKTOP | grep -i kde)" ] || [ -n "$$(pgrep plasmashell)" ]; then \
		export DE_TYPE=kde; \
	else \
		export DE_TYPE=unknown; \
	fi

install-gnome: install-script
	@mkdir -p "$(NAUTILUS_SCRIPTS_DIR)" >/dev/null 2>&1
	@ln -sf "$(INSTALL_DIR)/$(ICON_SCRIPT)" "$(NAUTILUS_SCRIPTS_DIR)/Извлечь иконку" >/dev/null 2>&1
	@echo "Создана ссылка для Nautilus..."
	@pkill nautilus >/dev/null 2>&1 || true

install-kde: install-script
	@mkdir -p "$(KDE_SERVICEMENU_DIR)" >/dev/null 2>&1
	@cp -f "$(DESKTOP_FILE)" "$(KDE_SERVICEMENU_DIR)/" >/dev/null 2>&1
	@echo "Desktop-файл скопирован в KDE servicemenus..."
	@kbuildsycoca6 >/dev/null 2>&1 || true

install-script:
	@mkdir -p "$(INSTALL_DIR)" >/dev/null 2>&1
	@cp -f "$(ICON_SCRIPT)" "$(INSTALL_DIR)/" >/dev/null 2>&1
	@chmod +x "$(INSTALL_DIR)/$(ICON_SCRIPT)" >/dev/null 2>&1
