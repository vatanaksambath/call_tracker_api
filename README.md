# Call_Tracker_API

> **INTERNAL PROJECT**

A modern RESTful API built with [NestJS](https://nestjs.com/) for streamlined management and processing of call tracker document and data.  
This API is engineered for internal use, offering robust endpoints for call tracker operations, document handling, and frictionless integration with internal call tracker information systems.

---

## 🚀 Table of Contents

- [Getting Started](#getting-started)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [API Endpoints](#api-endpoints)
- [Configuration](#configuration)
- [Testing & Deployment](#testing--deployment)
- [Contributing](#contributing)
- [License](#license)
- [Project Status](#project-status)

---

## 🏁 Getting Started

### 1. Clone the Repository

```sh
git clone https://github.com/vatanaksambath/call_tracker_api.git
cd call_tracker_api
```

### 2. Install Dependencies

```sh
npm install
```

### 3. Set Up Environment

- Copy `.env.example` to `.env`:
  ```sh
  cp .env.example .env
  ```
- Update environment variables as required.

---

## ✨ Features

- Secure call tracker data upload, retrieval, and processing
- RESTful endpoints for comprehensive call tracker data management
- Modular, scalable NestJS architecture (Controllers, Services, Modules)
- JWT authentication & role-based authorization
- Deep integration with internal call tracker systems
- Scalable and extensible by design

---

## ⚙️ Installation

**Requirements**
- Node.js 18.x or higher
- npm 9.x or higher
- (Optional) Docker & Docker Compose

**Install Dependencies**
```sh
npm install
```

**Environment Setup**
- Copy `.env.example` to `.env` and update values as needed.

---

## ▶️ Usage

**Local Development**
```sh
npm run start:dev
```

**Production**
```sh
npm run build
npm run start:prod
```

---

## 📚 API Endpoints

All endpoints require JWT authentication (`Authorization: Bearer <token>`). Permissions are enforced for every action.

> **See Swagger UI docs for up-to-date request/response schemas.**

### Authentication (`/auth`)

| Method | Endpoint     | Description                      | Request DTO               | Query Parameters      |
|--------|--------------|---------------------------------|---------------------------|----------------------|
| POST   | `/login`    | Login            | `LoginDTO`     | N/A                  |
| POST   | `/create`    | Create User       | `CreateUserDTO`     | N/A                  |
| POST   | `/reset-password`| Reset Password | `ResetPasswordDTO` | N/A                  |



### Project (`/project`)

| Method | Endpoint     | Description                      | Request DTO               | Query Parameters      |
|--------|--------------|---------------------------------|---------------------------|----------------------|
| POST   | `/insert`    | Create new project            | `CreateProjectDTO`     | N/A                  |
| PUT    | `/update`    | Update existing project       | `UpdateProjectDTO`     | N/A                  |
| GET    | `/:id`       | Get project by ID             | N/A                       | Path param: `id`     |
| POST   | `/pagination`| Get paginated list of project | `ProjectPaginationDTO` | N/A                  |
| PUT    | `/`          | Toggle project setting status | N/A                       | Query: `id`, `status`|

---


---
### Common (`/common`)

| Method | Endpoint                   | Description                      | Request DTO               | Path / Query Params           |
|--------|----------------------------|---------------------------------|---------------------------|------------------------------|
| GET    | `/address/province`        | Get all provinces               | N/A                       | N/A                          |
| GET    | `/address/district/:id`    | Get districts by province ID    | N/A                       | Path param: `id`             |
| GET    | `/address/commune/:id`     | Get communes by district ID     | N/A                       | Path param: `id`             |
| GET    | `/address/village/:id`     | Get villages by commune ID      | N/A                       | Path param: `id`             |
---

### Staff Info (`/staff`)

| Method | Endpoint | Description            | DTO |
|--------|----------|------------------------|-----|
| GET    | /info    | Get current staff info | N/A |

---

> **Notes**
> - All routes require authentication and the appropriate access permission.
> - For request/response JSON structures, refer to the DTO files or the Swagger API docs.
> - Standard HTTP error codes and error messages are returned on failure.

---

## ⚙️ Configuration

- All configuration is handled via `.env`.
- Key environment variables:
  - `POSTGRES_PORT`
  - `POSTGRES_HOST_IP`
  - `POSTGRES_USER`
  - `POSTGRES_PASSWORD`
  - `POSTGRES_DATABASE`
  - _...and more as needed_

---

## 🧪 Testing & Deployment

- Run tests:
  ```sh
  npm run test
  ```
- Lint code:
  ```sh
  npm run lint
  ```
- Use Docker Compose for rapid deployment:
  ```sh
  docker-compose up --build
  ```

---

## 🤝 Contributing

Pull requests are welcome for internal contributors! Please open an issue first to discuss proposed changes.

---

## 📄 License

This project is licensed for internal use only.

---

## 📈 Project Status

**Active development.**  
For status updates, see project issues & milestones.

---