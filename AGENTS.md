# Diccio
Diccio es un programa de línea de comandos para buscar definiciones de palabras en español.

Los resultados se obtienen de la [API de la RAE](https://rae-api.com/) y se guardan en una base
SQLite local. En cada corrida se consulta primero la base local y solo se va a la API si la palabra
no está guardada, así que la base funciona además como historial de lo buscado.

## Comandos

```shell
# Setup (Ruby 3.3.1, fijado en mise.toml y en el Gemfile)
mise install
bundle install

# Correr aplicación
bin/diccio casa              # Definiciones de una palabra
    --no-cache               # Ignorar la base local y volver a pedir la palabra a la RAE
    --history                # Historial completo de palabras buscadas
    --history 2026-08-30     # Historial de una fecha (YYYY-MM-DD)
    --help                   # Ayuda

# Tests y lint
bundle exec rake test
bundle exec rubocop

# Depuración
DICCIO_LOG_LEVEL=INFO bin/diccio casa    # Avisa cuando la palabra no está en la base y se consulta a la API
DICCIO_LOG_LEVEL=DEBUG bin/diccio casa   # Logs detallados de las requests HTTP
```

## Variables de entorno

| Variable | Default | Para qué |
|---|---|---|
| `DICCIO_DB` | `db.db` en la raíz del repo | Path del archivo SQLite |
| `DICCIO_API_URL` | `https://rae-api.com/api/` | Base URL de la API |
| `DICCIO_LOG_LEVEL` | `WARN` | Nivel del logger (a stderr) |
| `NO_COLOR` | — | Si está definida, se desactivan los colores |

## Estructura

`bin/diccio` despacha a `Diccio::CLI`, que parsea los flags a un `Options` y se lo pasa a
`Diccio::App`. `App` orquesta: pide al `Repository` y, si no hay nada, al `ApiClient`; después
delega la salida al `Formatter`. Cada capa habla en `Definition`, no en hashes crudos de la API ni
en filas de SQL.

- `cli.rb` es el único lugar que rescata errores y decide el exit code
- `api_client.rb` traduce `Faraday::Error` y las respuestas raras a `ApiError` / `NotFoundError`
- `database.rb` tiene la conexión y el schema; `repository.rb`, las queries; ambos traducen `SQLite3::Exception` a `DatabaseError`
- `formatter.rb` devuelve un string; el único `puts` de resultados está en `App#run` (el otro, el de `--help`, está en `cli.rb`)
- `options.rb` y `definition.rb` son los objetos de datos que circulan entre capas
- `style.rb` aplica colores (respeta `NO_COLOR` y que stdout sea una terminal); `logging.rb` construye el `Logger`
- `errors.rb` agrupa todos los errores en un solo archivo, como excepción a "un archivo por clase"

## Tests
- Minitest; un `*_test.rb` por unidad probada en `test/`, con helpers compartidos en `test/test_helper.rb`
- Sin red ni disco: la base va en memoria (`memory_repository`) y la API se simula con un
  adaptador de prueba de Faraday (`stub_client`)
- Las respuestas de la API viven como JSON en `test/fixtures/`
- `test_helper.rb` fija `NO_COLOR` y silencia el logger, así que la salida es texto plano
- Los nombres de los tests van en español (`test_guarda_y_recupera_en_orden_de_insercion`)

## Code style
- Respetar separación de responsabilidades
- snake_case para métodos y variables, CamelCase para clases y módulos
- Todo bajo el namespace `Diccio`, un archivo por clase o módulo, el path espeja el namespace
- Definir errores heredando `StandardError`, todos bajo `Diccio::Error`
- Traducir las excepciones ajenas a errores propios en el borde de cada capa
- Usar `Logger` para logs sobre puntos relevantes, nunca `puts` (stdout es la salida del programa)
- Usar patrón `ENV.fetch('KEY', default)` para variables de entorno
- Usar `attr_*` en lugar de getters explícitos
- Usar Faraday para requests HTTP, con 5 segundos de timeout
- Usar SQLite3 para la base de datos, siempre con bind params
- Inyectar colaboradores por keyword args con default concreto, para poder testear
- No comentar las funciones
- Mantener `.rubocop_todo.yml` vaciándose: si una excepción deja de hacer falta, se borra

## Misc
- Priorizar plan sobre ejecución. Realizar las preguntas necesarias
- Seguir los cuatro principios de calidad de escritura de Zinsser:
1. Simplicidad
2. Brevedad
3. Claridad
4. Humanidad
