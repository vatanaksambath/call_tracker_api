# Call_Tracker_API

> **INTERNAL PROJECT**

A modern RESTful API built with [NestJS](https://nestjs.com/) for streamlined management and processing of legal documents and data.  
This API is engineered for internal use, offering robust endpoints for legal operations, document handling, and frictionless integration with internal legal information systems.

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
git clone http://172.16.128.207:8929/root/npl_legal_api.git
cd npl_legal_api
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

- Secure legal document upload, retrieval, and processing
- RESTful endpoints for comprehensive legal data management
- Modular, scalable NestJS architecture (Controllers, Services, Modules)
- JWT authentication & role-based authorization
- Deep integration with internal legal systems
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

### Collateral (`/collateral`)

| Method | Endpoint     | Description                      | Request DTO               | Query Parameters      |
|--------|--------------|---------------------------------|---------------------------|----------------------|
| POST   | `/insert`    | Create new collateral            | `CreateCollateralDTO`     | N/A                  |
| PUT    | `/update`    | Update existing collateral       | `UpdateCollateralDTO`     | N/A                  |
| GET    | `/:id`       | Get collateral by ID             | N/A                       | Path param: `id`     |
| POST   | `/pagination`| Get paginated list of collateral | `CollateralPaginationDTO` | N/A                  |
| PUT    | `/`          | Toggle collateral setting status | N/A                       | Query: `id`, `status`|

---


---
### Common (`/common`)

| Method | Endpoint                   | Description                      | Request DTO               | Path / Query Params           |
|--------|----------------------------|---------------------------------|---------------------------|------------------------------|
| GET    | `/address/province`        | Get all provinces               | N/A                       | N/A                          |
| GET    | `/address/district/:id`    | Get districts by province ID    | N/A                       | Path param: `id`             |
| GET    | `/address/commune/:id`     | Get communes by district ID     | N/A                       | Path param: `id`             |
| GET    | `/address/village/:id`     | Get villages by commune ID      | N/A                       | Path param: `id`             |
| GET    | `/lawyer`                  | Get all lawyers                 | N/A                       | N/A                          |
| POST   | `/customer/pagination`     | Paginated customer listing      | `CustomerPaginationDTO`   | N/A                          |
| GET    | `/account`                 | Get account by customer ID and account number | N/A             | Query: `customerID`, `accountNO` |
| GET    | `/currency`                | Get all currencies              | N/A                       | N/A                          |
| GET    | `/judgement`               | Get judgement types            | N/A                       | N/A                          |
| GET    | `/appeal`                  | Get appeals                    | N/A                       | N/A                          |
| DELETE | `/appeal/:id`              | Delete appeal by ID            | N/A                       | Path param: `id`             |
| GET    | `/region`                  | Get all regions                | N/A                       | N/A                          |
| GET    | `/branch/:id`              | Get branch by ID               | N/A                       | Path param: `id`             |

---


### Complaint (`/complaint`)

| Method | Endpoint         | Description                          | Request DTO                 | Path / Query Params           |
|--------|------------------|------------------------------------|-----------------------------|------------------------------|
| POST   | `/insert`        | Create a new complaint              | `CreateNplComplaintDto`      | N/A                          |
| PUT    | `/update`        | Update an existing complaint        | `UpdateNplComplaintDto`      | N/A                          |
| PUT    | `/close`         | Close a complaint case              | `ComplaintCloseCaseDTO`      | N/A                          |
| POST   | `/pagination`    | Paginated list of complaints        | `ComplaintPaginationDTO`    | N/A                          |
| GET    | `/:id`           | Get complaint by ID                 | N/A                         | Path param: `id`             |
| POST   | `/export`        | Export complaint data (Excel)       | `ComplaintExportDTO`         | N/A                          |


---

### Complaint Type (`/complaint-type`)

| Method | Endpoint            | Description                          | Request DTO                  | Path / Query Params           |
|--------|---------------------|------------------------------------|------------------------------|------------------------------|
| POST   | `/insert`           | Create new complaint type           | `CreateComplaintTypeDTO`      | N/A                          |
| PUT    | `/update`           | Update an existing complaint type   | `UpdateComplaintTypeDTO`      | N/A                          |
| POST   | `/pagination`       | Paginated list of complaint types   | `ComplaintTypePaginationDTO` | N/A                          |
| GET    | `/:id`              | Get complaint type by ID             | N/A                          | Path param: `id`             |
| PUT    | `/`                 | Toggle setting status (enable/disable) | N/A                     | Query params: `id`, `status` |


---

### Sub Complaint Type (`/sub-complaint`)

| Method | Endpoint      | Description                       | Request DTO                     | Path / Query Params          |
| ------ | ------------- | --------------------------------- | ------------------------------- | ---------------------------- |
| POST   | `/insert`     | Create a new sub complaint type   | `CreateSubComplaintTypeDTO`     | N/A                          |
| PUT    | `/update`     | Update a sub complaint type       | `UpdateSubComplaintTypeDTO`     | N/A                          |
| GET    | `/:id`        | Get sub complaint type by ID      | N/A                             | Path param: `id`             |
| POST   | `/pagination` | Get paginated sub complaint types | `SubComplaintTypePaginationDTO` | N/A                          |
| PUT    | `/`           | Toggle setting update (status)    | N/A                             | Query params: `id`, `status` |


---

### Compulsory Execution (`/compulsary`)

| Method  | Endpoint               | Description                             | Request DTO                          | Path / Query Params          |
|---------|------------------------|---------------------------------------|------------------------------------|-----------------------------|
| POST    | `/insert`              | Create a new compulsory execution     | `CreateNPLCompulsoryDto`            | N/A                         |
| PUT     | `/update`              | Update an existing compulsory record  | `UpdateNPLCompulsoryDto`            | N/A                         |
| PUT     | `/close`               | Close a compulsory case                | `CompulsoryCloseCaseDTO`            | N/A                         |
| GET     | `/:id`                 | Get compulsory record by ID            | N/A                                | Path param: `id`            |
| DELETE  | `/:id`                 | Delete compulsory record by ID         | N/A                                | Path param: `id`            |
| POST    | `/pagination`          | Paginated list of compulsory records  | `CompulsoryPaginationDTO`           | N/A                         |
| POST    | `/complaint/pagination`| Paginated list of complaints related  | `ComplaintForCompulsoryPaginationDTO` | N/A                       |
| POST    | `/export`              | Export compulsory execution data       | `CompulsoryExportDTO`               | N/A                         |

---

### Appeal Court (`/appeal-court`)

| Method | Endpoint            | Description                        | Request DTO              | Path / Query Params            |
|--------|---------------------|----------------------------------|--------------------------|-------------------------------|
| POST   | `/insert`           | Create new appeal court record   | `CreateAppealCourtDTO`   | N/A                           |
| PUT    | `/update`           | Update an appeal court record    | `UpdateAppealCourtDTO`   | N/A                           |
| GET    | `/:id`              | Get appeal court by ID            | N/A                      | Path param: `id`              |
| POST   | `/pagination`       | Paginated appeal court listing   | `AppealCourtPaginationDTO`| N/A                          |
| PUT    | `/`                 | Toggle setting status (enable/disable) | N/A                  | Query params: `id`, `status`  |


---

### Sub Court (`/first-instance`)

| Method | Endpoint      | Description                       | Request DTO                  | Path / Query Params          |
| ------ | ------------- | --------------------------------- | ---------------------------- | ---------------------------- |
| POST   | `/insert`     | Create a new first instance       | `CreateFirstInstanceDTO`     | N/A                          |
| PUT    | `/update`     | Update an existing first instance | `UpdateFirstInstanceDTO`     | N/A                          |
| GET    | `/:id`        | Get first instance by ID          | N/A                          | Path param: `id`             |
| POST   | `/pagination` | Get paginated list of instances   | `FirstInstancePaginationDTO` | N/A                          |
| PUT    | `/`           | Toggle setting status             | N/A                          | Query params: `id`, `status` |


---

### Legal Advice (`/legal-advice`)

| Method | Endpoint      | Description                        | Request DTO                | Path / Query Params |
| ------ | ------------- | ---------------------------------- | -------------------------- | ------------------- |
| POST   | `/insert`     | Create new legal advice            | `CreateLegalAdviceDTO`     | N/A                 |
| PUT    | `/update`     | Update existing legal advice       | `UpdateLegalAdviceDTO`     | N/A                 |
| PUT    | `/close`      | Close a legal advice case          | `LegalAdviceCloseCaseDTO`  | N/A                 |
| GET    | `/:id`        | Get legal advice by ID             | N/A                        | Path param: `id`    |
| DELETE | `/:id`        | Delete legal advice by ID          | N/A                        | Path param: `id`    |
| POST   | `/pagination` | Get paginated list of legal advice | `LegalAdvicePaginationDTO` | N/A                 |
| POST   | `/export`     | Export legal advice data           | `LegalAdviceExportDTO`     | N/A                 |


---

### Legal Expense (`/legal-expense`)

| Method | Endpoint           | Description                       | Request DTO                     | Path / Query Params |
| ------ | ------------------ | --------------------------------- | ------------------------------- | ------------------- |
| POST   | `/insert`          | Create new legal expense          | `CreateLegalExpenseDTO`         | N/A                 |
| PUT    | `/update`          | Update existing legal expense     | `UpdateLegalExpenseDTO`         | N/A                 |
| POST   | `/pagination`      | Get paginated legal expenses      | `LegalExpensePaginationDTO`     | N/A                 |
| POST   | `/case/pagination` | Get paginated legal expense cases | `LegalExpenseCasePaginationDTO` | N/A                 |
| GET    | `/:id`             | Get legal expense by ID           | N/A                             | Path param: `id`    |
| DELETE | `/:id`             | Delete legal expense by ID        | N/A                             | Path param: `id`    |
| POST   | `/export`          | Export legal expense data         | `LegalExpenseExportDTO`         | N/A                 |


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
  - `UMS_DATABASE`
  - `DW_DATABASE`
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