# diccio

Buscador de definiciones de palabras en español sobre la API de la RAE, que guarda los resultados
en una base SQLite local para reusarlos y para llevar el historial de lo buscado.

```shell
bundle install

bin/diccio casa              # Definiciones de una palabra
bin/diccio --no-cache casa   # Ignorar la base local y volver a pedir la palabra a la RAE
bin/diccio --history         # Historial completo de palabras buscadas
bin/diccio --history 2026-08-30
```

La primera búsqueda de una palabra va a la API; las siguientes salen de la base local. Los mensajes
de diagnóstico van a stderr y están silenciados por default: `DICCIO_LOG_LEVEL=INFO` los muestra.

| Variable | Default | Para qué |
|---|---|---|
| `DICCIO_DB` | `db.db` en la raíz del repo | Path del archivo SQLite |
| `DICCIO_API_URL` | `https://rae-api.com/api/` | Base URL de la API |
| `DICCIO_LOG_LEVEL` | `WARN` | Nivel del logger |
| `NO_COLOR` | — | Si está definida, se desactivan los colores |

## Desarrollo

```shell
bundle exec rake test
bundle exec rubocop
```
