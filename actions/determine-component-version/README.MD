# determineComponentVersion

Github Action zur Bestimmung der Version einer Komponente. Es werden 2 Arten der Ermittlung unterstützt.
- basierend auf einer JIRA Komponente
- basierend auf dem last Tag

TODO: actions/create-version ist in diese Action zu integrieren

---

## Aufruf:

      - id: determine-component-version
        name: Determine Component Version
        uses: ./mcbscore-actions/actions/determine-component-version
