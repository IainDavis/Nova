openapi: 3.1.0
info:
  title: GitHub Repository File Access API
  description: API to access files and search for file paths in a GitHub repository.
  version: 1.1.0
servers:
  - url: https://api.github.com
    description: GitHub API
paths:
  /repos/{owner}/{repo}/compare/{base}...{head}:
    get:
      operationId: compareBranches
      summary: Compare two branches to see the changes.
      description: Compare the specified branch or commit (head) with another branch or commit (base). Returns a list of commits and a diff of changes.
      parameters:
        - name: owner
          in: path
          required: true
          description: GitHub username or organization name.
          schema:
            type: string
        - name: repo
          in: path
          required: true
          description: The repository name.
          schema:
            type: string
        - name: base
          in: path
          required: true
          description: The base branch or commit to compare against.
          schema:
            type: string
        - name: head
          in: path
          required: true
          description: The head branch or commit to compare with the base.
          schema:
            type: string
      responses:
        '200':
          description: The comparison was successful, and the list of commits and changes are returned.
          content:
            application/json:
              schema:
                type: object
                properties:
                  commits:
                    type: array
                    description: List of commits between the base and head.
                    items:
                      type: object
                      properties:
                        sha:
                          type: string
                          description: The commit SHA.
                        commit:
                          type: object
                          description: Commit details.
                          properties:
                            message:
                              type: string
                              description: The commit message.
                            author:
                              type: object
                              properties:
                                name:
                                  type: string
                                  description: Author's name.
                                date:
                                  type: string
                                  format: date-time
                                  description: Commit date.
                  files:
                    type: array
                    description: List of files changed in the comparison.
                    items:
                      type: object
                      properties:
                        filename:
                          type: string
                          description: Name of the file.
                        status:
                          type: string
                          description: The status of the file (added, modified, removed).
                        changes:
                          type: integer
                          description: Number of changes in the file.

  /repos/{owner}/{repo}/pulls:
    post:
      operationId: createPullRequest
      summary: Create a new pull request.
      description: Create a pull request from one branch to another, optionally with a title and body.
      parameters:
        - name: owner
          in: path
          required: true
          description: GitHub username or organization name.
          schema:
            type: string
        - name: repo
          in: path
          required: true
          description: The repository name.
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - title
                - head
                - base
              properties:
                title:
                  type: string
                  description: The title of the pull request.
                head:
                  type: string
                  description: The name of the branch where your changes are implemented.
                base:
                  type: string
                  description: The name of the branch you want the changes pulled into (usually the default branch like `main`).
                body:
                  type: string
                  description: The contents of the pull request description.
                draft:
                  type: boolean
                  description: Indicates if the PR should be created as a draft PR.
      responses:
        '201':
          description: The pull request was created successfully.
          content:
            application/json:
              schema:
                type: object
                properties:
                  html_url:
                    type: string
                    description: The URL of the created pull request.
                  number:
                    type: integer
                    description: The number of the pull request.
        '403':
          description: Access to the repository is forbidden.
        '401':
          description: Authentication failed.
        '422':
          description: Validation failed, such as if the head and base branches are identical or there is an existing open PR.
    get:
      operationId: listPullRequests
      summary: List recent pull requests in a repository.
      description: Retrieve a list of recent pull requests in a GitHub repository.
      parameters:
        - name: owner
          in: path
          required: true
          description: GitHub username or organization name.
          schema:
            type: string
        - name: repo
          in: path
          required: true
          description: The repository name.
          schema:
            type: string
        - name: state
          in: query
          required: false
          description: The state of the PR (open, closed, all). Defaults to 'open'.
          schema:
            type: string
            enum: [open, closed, all]
        - name: sort
          in: query
          required: false
          description: The sort order of the results. Can be 'created' or 'updated'. Default is 'created'.
          schema:
            type: string
            enum: [created, updated]
        - name: direction
          in: query
          required: false
          description: The direction of sorting. Can be 'asc' or 'desc'. Default is 'desc'.
          schema:
            type: string
            enum: [asc, desc]
      responses:
        '200':
          description: A list of pull requests.
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
                  properties:
                    id:
                      type: integer
                      description: The ID of the pull request.
                    number:
                      type: integer
                      description: The number of the pull request.
                    state:
                      type: string
                      description: The state of the pull request (open, closed).
                    title:
                      type: string
                      description: The title of the pull request.
                    created_at:
                      type: string
                      format: date-time
                      description: The time when the PR was created.
                    updated_at:
                      type: string
                      format: date-time
                      description: The time when the PR was last updated.
                    html_url:
                      type: string
                      description: URL to view the pull request on GitHub.
        '403':
          description: Access to the repository is forbidden.
        '401':
          description: Authentication failed.

  /repos/{owner}/{repo}/pulls/{pull_number}/reviews:
    post:
      operationId: createPullRequestReview
      summary: Submit a review on a pull request.
      description: Submit a review on the specified pull request.
      parameters:
        - name: owner
          in: path
          required: true
          description: GitHub username or organization name.
          schema:
            type: string
        - name: repo
          in: path
          required: true
          description: The repository name.
          schema:
            type: string
        - name: pull_number
          in: path
          required: true
          description: The number of the pull request.
          schema:
            type: integer
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - body
                - event
              properties:
                body:
                  type: string
                  description: The content of the review.
                event:
                  type: string
                  description: The action to take with the review.
                  enum: [APPROVE, REQUEST_CHANGES, COMMENT]
      responses:
        '200':
          description: Review submitted successfully.
        '403':
          description: Access to the repository is forbidden.
        '401':
          description: Authentication failed.
        '422':
          description: Validation failed (e.g., invalid review state).
    
components:
  schemas: {}
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
security:
  - bearerAuth: []
