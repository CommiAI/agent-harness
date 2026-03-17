---
name: review-api-design
description: Review API design, plan or implementation
---

# Review API Design 

## Overview
Help review designs, plans or implementations of APIs against a list of best practices.
For each endpoint and use case, follow through these best practices to ensure the API is well-designed.

## Naming
Use nouns to represent resources, use pluralized nouns for resources.
If one object can consist of another object, leverage logical grouping by reflecting object relationship.
Collection is a group of resources, e.g. /orders 
Do not go deeper than collection/resource/collection in API design.
Use hyphens to improve readability.
Use versioning to manage API changes, e.g. example.com/v1/store
Use HATEOAS to provide links for navigation and actions.
Follow OpenAPI Specification

## Filtering sorting and pagination
Filter data by specific key-values
Fetch only specific fields by key
Limit the number of items for the data returned
Paginate the data chunk by chunk instead of querying all at once
Sort the data by a specific key-value

### Idempotency
API requests should be idempotent. Look out for POST and PATCH operations. E.g. completing a form via POST should have the same effect as re-submitting the same form.
HTTP status codes in the response may differ
E.g. First DELETE request: 204 (No Content) -> Second DELETE request: 404 (Not Found)

## Async operations
Async operations return a 202 (Accepted) response with a location header pointing to the async operation status endpoint, optionally including estimated completion time and link to the cancel endpoint if needed.
Status endpoints return 303 (See Other) with a location header pointing to the URL to the new resource if the endpoints create a new resource.

## Partial responses
Assets should be able to be retrieved in chunks with Accept Ranges header for specific byte ranges of resources.
Include HTTP head requests for retrieving metadata without downloading the entire resource.
Partial Content response with 206 with metadata about the requested range.

## Error handling
Error response should include a clear error message and correct HTTP status code, with exposure of internal mechanics avoided.

## Security
Make SSL/TLS encryption default for all API endpoints
Authorization with Access Control Lists
