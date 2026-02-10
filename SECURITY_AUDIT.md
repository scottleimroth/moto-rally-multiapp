# Moto Rally Australia - Security Audit Checklist

## ABSOLUTE RULE: CREDENTIALS.md MUST NEVER BE PUBLIC

- CREDENTIALS.md must ALWAYS be listed in .gitignore -- no exceptions
- It must NEVER be committed to git, pushed to any remote, or exposed in any public or shared location
- If accidentally committed, treat as a full breach: rotate ALL keys/secrets immediately and scrub from git history

---

## Audit Checklist

### 1. Credentials & Secrets Exposure (CHECK FIRST -- EVERY TIME)

- [ ] CREDENTIALS.md exists and is listed in .gitignore
- [ ] .env file exists and is listed in .gitignore
- [ ] No API keys, tokens, passwords, or secrets hardcoded anywhere in source code
- [ ] No secrets in git history
- [ ] All credentials loaded via environment variables, never string literals
- [ ] All .gitignore entries confirmed: .env, CREDENTIALS.md, *.key, *.pem

### 2. Input & Data Handling

- [ ] ALL user inputs sanitised
- [ ] Protected against XSS (output encoding, CSP headers)
- [ ] Error handling doesn't leak system info
- [ ] JSON parsing handles malformed input gracefully

### 3. Network & API Security

- [ ] HTTPS enforced everywhere
- [ ] CORS policy properly configured
- [ ] API rate limiting considered for scraping

### 4. Dependencies & Supply Chain

- [ ] All packages audited: `flutter pub audit`
- [ ] Python scraper dependencies reviewed
- [ ] No abandoned or unmaintained packages

### 5. Deployment & Infrastructure

- [ ] Debug mode DISABLED in production builds
- [ ] GitHub Actions workflows reviewed for secret exposure
- [ ] No default credentials on any service

---

## Known Risks & Accepted Trade-offs

| Risk | Reason Accepted | Mitigation | Review Date |
|------|----------------|------------|-------------|
| Web scraping may break if sites change | Only way to aggregate events | Weekly GitHub Actions run, manual review | 2026-06-01 |

---

## Incident Log

| Date | Incident | Action Taken | Resolved |
|------|----------|-------------|----------|
|      |          |             |          |

---

**Last audited:** 2026-02-10
**Audited by:** Claude Code
**Next audit due:** 2026-05-10
