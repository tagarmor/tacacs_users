#!/bin/bash

# Ruta al archivo de configuración tac_plus.conf
config_file="/etc/tac_plus.conf"

# Buscar secciones de definición de usuario en el archivo de configuración
user_sections=$(grep -nE 'user = [[:alnum:]_\-]+' $config_file | cut -d':' -f1)

# Recorrer cada sección de usuario y extraer el nombre de usuario
users=()
for section in $user_sections; do
  user=$(sed -n "$section"'{s/user = \([[:alnum:]_\-]\+\).*/\1/p;q}' $config_file)
  users+=("$user")
done

# Analizar el archivo tac_plus.conf y asociar el nombre de usuario con su campo "group"
declare -A user_groups
while read -r line; do
  if [[ $line =~ ^user\ =\ ([[:alnum:]_\-]+) ]]; then
    user="${BASH_REMATCH[1]}"
  elif [[ $line =~ ^\ *member\ =\ ([[:alnum:]_\-]+) ]]; then
    group="${BASH_REMATCH[1]}"
    user_groups["$user"]="$group"
  fi
done < "$config_file"

# Mostrar la lista de usuarios con su campo "group" asociado
echo "Usuarios definidos en el archivo de configuración:"
for user in "${users[@]}"; do
  group="${user_groups[$user]}"
  echo "$user:$group"
done
