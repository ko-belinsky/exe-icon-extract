# Makefile для установки скрипта извлечения иконок

.PHONY: install check-icoutils install-gnome install-kde

INSTALL_DIR = $(HOME)/.local/bin
ICON_SCRIPT = exe-icon-extract.sh
DESKTOP_FILE = exe-icon-extract.desktop

# Основная цель установки
install: check-icoutils detect-de install-script
	@echo "Установка завершена успешно."

# Проверка и установка icoutils
check-icoutils:
	@if ! command -v wrestool >/dev/null 2>&1; then \
		echo "icoutils не установлен, пытаюсь установить..."; \
		if [ -x "$(command -v su)" ]; then \
			su -c 'apt-get install -y icoutils' && echo "icoutils успешно установлен."; \
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
		$(MAKE) install-gnome; \
	elif [ -n "$$(echo $$XDG_CURRENT_DESKTOP | grep -i kde)" ] || [ -n "$$(pgrep plasmashell)" ]; then \
		$(MAKE) install-kde; \
	else \
		echo "Не удалось определить окружение (GNOME/KDE), устанавливаю только скрипт..."; \
		$(MAKE) install-script; \
	fi

# Установка для GNOME
install-gnome: install-script
	@mkdir -p "$(HOME)/.local/share/nautilus/scripts"
	@ln -sf "$(INSTALL_DIR)/$(ICON_SCRIPT)" "$(HOME)/.local/share/nautilus/scripts/Извлечь иконку"
	@echo "Создана ссылка для Nautilus..."
	@pkill nautilus || true

# Установка для KDE
install-kde: install-script
	@mkdir -p "$(HOME)/.local/share/kservices5/servicemenus"
	@cp -f "$(DESKTOP_FILE)" "$(HOME)/.local/share/kservices5/servicemenus/"
	@echo "Desktop-файл скопирован для KDE..."
	@kbuildsycoca6 || true

# Установка основного скрипта
install-script:
	@mkdir -p "$(INSTALL_DIR)"
	@cp -f "$(ICON_SCRIPT)" "$(INSTALL_DIR)/"
	@chmod +x "$(INSTALL_DIR)/$(ICON_SCRIPT)"
	@echo "Скрипт установлен в $(INSTALL_DIR)"
