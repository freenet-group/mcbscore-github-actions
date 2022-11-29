# custom Repository Settings
  Hier können einzelne spezielle settings Dateien für die einzelnen Repos angelegt werden.
  Falls man für ein Repository kein speziellen Anpassungen möchte. kann auch die base-settings.yml direkt eingebunden werden.
  
  Für ein Anpassen ist folgendes Nötig:
  
  ## Anpassungen im Ziel Repository
  Im Ziel Repository die <code>.github/settings.yml</code> anpassen:
  <br>
  Ohne Anpassungen:
  <br>
  <code>_extends: freenet-group/mcbscore-github-actions/config/probot/base-settings.yml</code>
  <br>
  Mit Anpassungen:
  <br>
 <code>_extends: freenet-group/mcbscore-github-actions/config/probot/ms/ms-{anwendungsname}.yml</code> 
  
  ## Anpassungen in mcbscore-github-actions
  Erstellen von <code>config/probot/ms/ms-{anwendungsname}.yml</code> 
  <br>
  Inhalt ist hierbei:
  <br>
  <code>_extends: freenet-group/mcbscore-github-actions/config/probot/baseSettings.yml</code>
  <br>
  Nach dem <code>_extends</code> Eintrag Einstellngen hinzufügen die für dieses Repository überschrieben werden sollen.
  
  
