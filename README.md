Infraestructura local para el sistema de gestión de incidentes. Orquesta todos los servicios necesarios mediante Docker Compose.

## Servicios incluidos

| Servicio | Tecnología | Puerto | Descripción |
|----------|-----------|--------|-------------|
| `sqlserver` | MS SQL Server 2022 | 1433 | Base de datos relacional |
| `sqlserver-init` | - | - | Inicializa el esquema y datos de prueba |
| `mongodb` | MongoDB 7 | 27017 | Base de datos de eventos |
| `mock-service` | Node.js + Express | 3001 | Catálogo de servicios mock |
| `incident-api` | Python (Backend API) | 8000 | API REST principal |
| `incident-web` | Frontend | 4200 | Interfaz web |

## Prerrequisitos

- [Docker](https://www.docker.com/products/docker-desktop) >= 20.x
- [Docker Compose](https://docs.docker.com/compose/) >= 2.x
- Git

## Repositorios necesarios

Este proyecto referencia otros dos repositorios que deben estar clonados al mismo nivel que este directorio:

```
workspace/
├── incident_infra/   ← este repositorio
├── incident_api/     ← repositorio del backend
└── incident_web/     ← repositorio del frontend
```

Clona los tres repositorios:

```bash
git clone <url-incident_infra>
git clone <url-incident_api>
git clone <url-incident_web>
```

## Levantar el entorno

### 1. Construir y arrancar todos los servicios

Desde el directorio `incident_infra`:

```bash
cd incident_infra
docker compose up --build
```

> La primera vez tardará varios minutos mientras descarga las imágenes base y construye los contenedores.

### 2. Verificar que todos los servicios estén sanos

```bash
docker compose ps
```

Todos los servicios deben aparecer con estado `healthy` o `running`.

### 3. Acceder a la aplicación

Una vez levantados los servicios:

- **Frontend (web):** http://localhost:4200
- **API (backend):** http://localhost:8000
- **Mock service catalog:** http://localhost:3001
- **SQL Server:** `localhost:1433` (usuario: `sa`, contraseña: `Incident@2026!`)
- **MongoDB:** `mongodb://localhost:27017`

## Arranque sin reconstruir imágenes

Si ya construiste las imágenes previamente y solo quieres arrancar los servicios:

```bash
docker compose up
```

## Detener el entorno

```bash
docker compose down
```

Para detener y eliminar también los volúmenes (esto borrará los datos de las bases de datos):

```bash
docker compose down -v
```

## Logs

Ver logs de todos los servicios:

```bash
docker compose logs -f
```

Ver logs de un servicio específico:

```bash
docker compose logs -f incident-api
docker compose logs -f incident-web
docker compose logs -f sqlserver
```

## Variables de entorno

Las variables de entorno del backend están configuradas directamente en `docker-compose.yml`:

| Variable | Valor |
|----------|-------|
| `SQL_SERVER_HOST` | sqlserver |
| `SQL_SERVER_PORT` | 1433 |
| `SQL_SERVER_DB` | IncidentDB |
| `SQL_SERVER_USER` | sa |
| `SQL_SERVER_PASSWORD` | Incident@2026! |
| `MONGODB_URI` | mongodb://mongodb:27017 |
| `MONGODB_DB` | incident_events_db |
| `SERVICE_CATALOG_URL` | http://mock-service:3001 |

## Base de datos

El contenedor `sqlserver-init` ejecuta automáticamente el script `sql/init.sql` al arrancar, creando:

- Base de datos `IncidentDB`
- Tabla `Incidents` con campos de título, descripción, severidad, estado y servicio asociado
- 5 incidentes de prueba preinsertados

## Orden de arranque

Los servicios arrancan en el siguiente orden respetando las dependencias de salud:

1. `sqlserver` y `mongodb` (en paralelo)
2. `sqlserver-init` (espera a que `sqlserver` esté healthy)
3. `mock-service`
4. `incident-api` (espera a que `sqlserver`, `mongodb` y `mock-service` estén healthy)
5. `incident-web` (espera a que `incident-api` esté healthy)
