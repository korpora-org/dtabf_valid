# A validator for DTABf

This validator for DTABf was originally developed in
[CLARIAH-DE](https://www.clariah.de/edieren-annotieren) for evaluating
the DTABf as a format for editions (see paper below for the context).

It runs with Java 11+. Build with

```sh
mvn package dependency:copy-dependencies
```

Run with

```sh
      java -jar target/dtabf-valid-0.1-SNAPSHOT.jar ../SUB-bdn/data
```

The program produces two files:

- `errors.json` – which documents errors with respect to the DTABf schema(tron) per document. Errors are only reported for the first document to keep the list manageable.

  For [RelaxNG](https://relaxng.org/) errors, error lines and co-ordinates are reported.

  For [Schematron](https://www.schematron.com/) errors, such a report is not available.

- `errors.md`, a [Markdown](https://de.wikipedia.org/wiki/Markdown) giving all error messages and error counts, but no information on single occurrences.



# References

Bernhard Fisseni, Simon Sendler; Daniela Schulz, Matthias Boenig, Hanna-Lena Meiners, and Uwe Sikora. Das DTABf in der Edition - zusammenfassender Evaluationsbericht. Arbeitsbericht. CLARIAH-DE-Arbeitsberichte 1, July 2021. [https://doi.org/10.14618/ids-pub-10496](https://doi.org/10.14618/ids-pub-10496).

