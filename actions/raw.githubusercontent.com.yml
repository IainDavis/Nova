openapi: 3.1.0
info:
  title: GitHub Repository Raw File URLs
  description: API to find and retrieve raw files from GitHub repositories.
  version: 1.1.0
servers:
  - url: https://raw.githubusercontent.com/
    description: GitHub Raw Files

paths:
  /{owner}/{repository}/refs/heads/metadata/repository-maps/{branch}/repository-map.txt:
    get:
      operationId: getRepositoryMap
      summary: Retrieve a map of the repository's file structure at the head of a given branch
      description: Fetch a file from raw.githubusercontent.com
      parameters:
        - name: owner
          in: path
          required: true
          description: GitHub username or organization name. The default owner is 'IainDavis'.
          schema:
            type: string

        - name: repository
          in: path
          required: true
          description: The repository name. The default repository is 'iaindavis.github.io'.
          schema:
            type: string
            
        - name: branch
          in: path
          required: true
          description: The branch from which the file should be fetched. The default branch is 'main'.
          schema:
            type: string

      responses:
        '200':
          description: The map was retrieved successfully.
        '304':
          description: The map was retrieved successfully after a redirect.
        '404':
          description: Could not find a file at that path location.

  /{owner}/{repository}/refs/heads/{branch}/{path-to-file}:
    get:
      operationId: getFile
      summary: Retrieve a raw file from a public GitHub repository. If the path-to-file is not clear, fetch the repository map using the relevant action and infer the file path from the result.
      description: Fetch a file from raw.githubusercontent.com
      parameters:
        - name: owner
          in: path
          required: true
          description: GitHub username or organization name. Default 'IainDavis'.
          schema:
            type: string

        - name: repository
          in: path
          required: true
          description: The repository name. Default 'iaindavis.github.io'.
          schema:
            type: string
            
        - name: branch
          in: path
          required: true
          description: The branch from which the file should be fetched.
          schema:
            type: string
        
        - name: path-to-file
          in: path
          required: true
          description: The fully qualified path (including filename and extension) of the requested file, relative to the root of the repository.
          schema:
            type: string

      responses:
        '200':
          description: The file was retrieved successfully.
        '304':
          description: The file was retrieved successfully after a redirect.
        '404':
          description: Could not find a file at that path location.

components:
  schemas: {}
