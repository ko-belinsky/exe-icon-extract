# Makefile для установки скрипта извлечения иконок (тихая версия)

.PHONY: install check-icoutils install-gnome install-kde detect-de install-script

INSTALL_DIR = $(HOME)/.local/bin
ICON_SCRIPT = exe-icon-extract.sh
DESKTOP_FILE = exe-icon-extract.desktop

# Основная цель установки
install:
	@$(MAKE) --no-print-directory check-icoutils
	@$(MAKE) --no-print-directory detect-de
	@$(MAKE) --no-print-directory install-script
	@echo "Установка завершена успешно."

# Проверка и установка icoutils
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

# Определение DE
detect-de:
	@if [ -n "$$(echo $$XDG_CURRENT_DESKTOP | grep -i gnome)" ] || [ -n "$$(pgrep gnome-session)" ]; then \
		$(MAKE) --no-print-directory install-gnome; \
	elif [ -n "$$(echo $$XDG_CURRENT_DESKTOP | grep -i kde)" ] || [ -n "$$(pgrep plasmashell)" ]; then \
		$(MAKE) --no-print-directory install-kde; \
	else \
		echo "Не удалось определить окружение (GNOME/KDE), устанавливаю только скрипт..."; \
		$(MAKE) --no-print-directory install-script; \
	fi

# Установка для GNOME
install-gnome: install-script
	@mkdir -p "$(HOME)/.local/share/nautilus/scripts" >/dev/null 2>&1
	@ln -sf "$(INSTALL_DIR)/$(ICON_SCRIPT)" "$(HOME)/.local/share/nautilus/scripts/Извлечь иконку" >/dev/null 2>&1
	@echo "Создана ссылка для Nautilus..."
	@pkill nautilus >/dev/null 2>&1 || true

# Установка для KDE
install-kde: install-script
	@mkdir -p "$(HOME)/.local/share/kservices5/servicemenus" >/dev/null 2>&1
	@cp -f "$(DESKTOP_FILE)" "$(HOME)/.local/share/kservices5/servicemenus/" >/dev/null 2>&1
	@echo "Desktop-файл скопирован для KDE..."
	@kbuildsycoca6 >/dev/null 2>&1 || true

# Установка основного скрипта
install-script:
	@mkdir -p "$(INSTALL_DIR)" >/dev/null 2>&1
	@cp -f "$(ICON_SCRIPT)" "$(INSTALL_DIR)/" >/dev/null 2>&1
	@chmod +x "$(INSTALL_DIR)/$(ICON_SCRIPT)" >/dev/null 2>&1
	@echo "Скрипт установлен в $(INSTALL_DIR)"
