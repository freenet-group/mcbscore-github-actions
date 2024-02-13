# dependabot aktivieren und konfigurieren
# dependabot.yml
# https://docs.github.com/en/code-security/supply-chain-security/keeping-your-dependencies-updated-automatically/configuration-options-for-dependency-updates
# github packages müssen hinzugefügt werden, da der dependabot sonst mit einem Fehler abgestürzt. Das Secret GH_R_PACKAGES  sollte in den Repos bereits hinterlegt worden sein.
# Der Wert open-pull-requests-limit muss auf > 0 gestellt werden. Wenn die auf 0 steht wird der [Dependency-Graph](../actions/init-workflow/action.yml) nicht ausgewertet und dependabot tut gar nichts.
