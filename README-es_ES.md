# Rootless-DevBox

Una solución simple y automatizada para instalar Devbox en un entorno sin root, sin requerir privilegios de sudo o root.

[![GitHub License](https://img.shields.io/github/license/nebstudio/Rootless-DevBox)](https://github.com/nebstudio/Rootless-DevBox/blob/main/LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/nebstudio/Rootless-DevBox?style=social)](https://github.com/nebstudio/Rootless-DevBox/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/nebstudio/Rootless-DevBox)](https://github.com/nebstudio/Rootless-DevBox/issues)

## ¿Qué es Rootless-DevBox?

Rootless-DevBox es un proyecto que permite a los usuarios instalar y usar [Devbox](https://github.com/jetify-com/devbox) en entornos donde no tienen acceso root, como hosting compartido, sistemas universitarios o entornos corporativos restringidos. Utiliza [nix-user-chroot](https://github.com/nix-community/nix-user-chroot) para crear un entorno aislado donde Nix y Devbox pueden ejecutarse sin privilegios elevados.

## Características

- 🛡️ **No requiere root**: Instala y usa Devbox sin sudo ni root
- 🔄 **Entorno aislado**: Ejecuta paquetes en un entorno contenido sin afectar el sistema
- 🚀 **Instalación fácil**: Un solo script para configurar todo automáticamente
- 💻 **Multiplataforma**: Funciona en varias distribuciones y arquitecturas de Linux
- 🔒 **Seguro**: Solo modifica tu entorno de usuario, no los archivos del sistema

## Inicio rápido

> **Nota:**  
> El script de instalación es intencionadamente interactivo y te pedirá confirmaciones en varios pasos.  
> Esto está diseñado así para que puedas tomar decisiones durante la instalación, entender cada paso y adaptar el proceso a tu entorno.  
> No te desanimes por los mensajes adicionales: este enfoque maximiza la compatibilidad y el control del usuario, especialmente en entornos Linux diversos o restringidos.

Simplemente ejecuta este comando en tu terminal:

```bash
# Descarga el instalador
curl -o rootless-devbox-installer.sh https://raw.githubusercontent.com/nebstudio/Rootless-DevBox/main/install.sh

# Hazlo ejecutable
chmod +x rootless-devbox-installer.sh

# Ejecuta el instalador
./rootless-devbox-installer.sh
```

## ¿Cómo funciona?

Rootless-DevBox configura tu entorno en 3 pasos principales:

1. **Instala nix-user-chroot**: Descarga y configura una herramienta que crea un entorno chroot en espacio de usuario
2. **Crea el entorno Nix**: Configura un entorno Nix aislado en tu directorio de usuario
3. **Instala Devbox**: Instala Devbox dentro de este entorno para que puedas usarlo sin root

Después de la instalación, accederás a tu entorno de desarrollo usando el comando `nix-chroot`, que activa el entorno aislado donde Devbox está disponible.

## Uso

### Entrar al entorno Nix

Después de la instalación, entra al entorno Nix ejecutando:

```bash
nix-chroot
```

Verás que tu prompt cambia para indicar que estás en el entorno nix-chroot:

```
(nix-chroot) usuario@host:~$
```

### Usar Devbox

Dentro del entorno nix-chroot, puedes usar Devbox normalmente:

```bash
# Mostrar ayuda
devbox help

# Inicializar un nuevo proyecto
devbox init

# Agregar paquetes
devbox add nodejs python

# Iniciar un shell con tu entorno de desarrollo
devbox shell
```

### Salir del entorno

Para salir del entorno nix-chroot:

```bash
exit
```

## Requisitos

- Sistema operativo basado en Linux
- Shell Bash
- Conexión a Internet
- ¡No se necesita acceso root!

## Arquitecturas soportadas

- x86_64
- aarch64/arm64
- armv7
- i686/i386

## Solución de problemas

### Problemas comunes

**P: Me sale "command not found" al intentar usar nix-chroot.**  
R: Asegúrate de que `~/.local/bin` esté en tu PATH. Prueba ejecutando `source ~/.bashrc` o reinicia tu terminal.

**P: La instalación falla al descargar nix-user-chroot.**  
R: Verifica tu conexión a Internet. Si el problema persiste, intenta descargar el binario adecuado manualmente desde [la página de releases](https://github.com/nix-community/nix-user-chroot/releases).

**P: No puedo instalar paquetes en el entorno Nix.**  
R: Algunos sistemas tienen cuotas o limitaciones de espacio en disco. Verifica tu espacio disponible con `df -h ~`.

Para más ayuda, por favor [abre un issue](https://github.com/nebstudio/Rootless-DevBox/issues).

## Desinstalación

Si necesitas eliminar Rootless-DevBox de tu sistema, tienes dos opciones:

### Opción 1: Usar el script de desinstalación

Proveemos un script para eliminar la mayoría de los componentes:

```bash
# Descarga el desinstalador
curl -o rootless-devbox-uninstaller.sh https://raw.githubusercontent.com/nebstudio/Rootless-DevBox/main/uninstall.sh

# Hazlo ejecutable
chmod +x rootless-devbox-uninstaller.sh

# Ejecuta el desinstalador
./rootless-devbox-uninstaller.sh
```

### Opción 2: Desinstalación manual (recomendada)

Para mayor control, puedes eliminar los componentes manualmente:

1. **Elimina los binarios instalados**:
   ```bash
   rm -f ~/.local/bin/devbox
   rm -f ~/.local/bin/nix-chroot
   rm -f ~/.local/bin/nix-user-chroot
   ```

2. **Limpia el directorio de Nix** (opcional, elimina todos los paquetes de Nix):
   ```bash
   rm -rf ~/.nix
   ```

3. **⚠️ IMPORTANTE: Edita tu archivo de configuración de shell** (`~/.bashrc`, `~/.zshrc`, etc.):

   **Muy recomendado**: Revisa y elimina manualmente las siguientes líneas en vez de depender de una limpieza automática:
   
   - Elimina la línea de modificación de PATH:
     ```bash
     export PATH="$HOME/.local/bin:$PATH" # Added by Rootless-DevBox
     ```
   
   - Elimina el bloque de modificación de PS1:
     ```bash
     # Rootless-DevBox nix-chroot environment indicator
     if [ "$NIX_CHROOT" = "1" ]; then
       PS1="(nix-chroot) \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
     fi
     ```

   Después de editar, aplica los cambios:
   ```bash
   source ~/.bashrc  # o tu archivo de configuración de shell específico
   ```

> **Nota**: Aunque el script de desinstalación intenta editar tu archivo de configuración de shell de forma segura, **revisar y eliminar manualmente las líneas específicas** es lo más seguro para evitar modificaciones no deseadas.

Después de desinstalar, puede que necesites abrir una nueva sesión de terminal para que todos los cambios tengan efecto.

## Contribuir

¡Las contribuciones son bienvenidas! No dudes en enviar un Pull Request.

1. Haz un fork del repositorio
2. Crea una rama de funcionalidad: `git checkout -b feature/mi-funcionalidad`
3. Haz tus cambios: `git commit -m 'Agrega mi funcionalidad'`
4. Sube la rama: `git push origin feature/mi-funcionalidad`
5. Abre un Pull Request

## Agradecimientos

Este proyecto no sería posible sin estos increíbles proyectos:

- [nix-user-chroot](https://github.com/nix-community/nix-user-chroot) - Permite ejecutar Nix como usuario sin root
- [Devbox](https://github.com/jetify-com/devbox) - Excelente herramienta de entorno de desarrollo
- [Nix](https://nixos.org/) - El potente sistema de gestión de paquetes subyacente

## Licencia

Este proyecto está licenciado bajo la licencia MIT - consulta el archivo [LICENSE](LICENSE) para más detalles.

## Consideraciones de seguridad

Rootless-DevBox solo modifica archivos dentro del directorio home del usuario y no requiere ni usa privilegios de root. Está diseñado para ser seguro incluso en entornos restringidos.

---

⭐ ¡Si este proyecto te ha sido útil, considera darle una estrella en GitHub! ⭐

Creado con ❤️ por [nebstudio](https://github.com/nebstudio)