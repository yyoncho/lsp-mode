;;; lsp-mssql.el --- LSP mode                              -*- lexical-binding: t; -*-

(lsp-register-client
 (make-lsp-client :new-connection
                  (lsp-stdio-connection
                   (lambda ()
                     (list "/home/kyoncho/.vscode/extensions/ms-mssql.mssql-1.7.1/sqltoolsservice/1.7.1/Ubuntu16/MicrosoftSqlToolsServiceLayer-backup")))
                  :major-modes '(sql-mode)
                  :priority -1
                  :notification-handlers (ht ("objectexplorer/expandCompleted" #'lsp-mssql--expand-completed)
                                             ("objectexplorer/sessioncreated" 'lsp-mssql--session-created))
                  :server-id 'sql
                  :initialized-fn (lambda (workspace)
                                    (puthash "explorer" (ht) (lsp--workspace-metadata workspace))
                                    (with-lsp-workspace workspace
                                      (lsp--set-configuration (json-parse-string "{\n    \"mssql\": {\n        \"logDebugInfo\": false,\n        \"maxRecentConnections\": 5,\n        \"connections\": [{\n            \"server\": \"localhost\",\n            \"database\": \"\",\n            \"authenticationType\": \"SqlLogin\",\n            \"user\": \"SA\",\n            \"password\": \"\",\n            \"emptyPasswordInput\": false,\n            \"savePassword\": true\n        }],\n        \"shortcuts\": {\n            \"_comment\": \"Short cuts must follow the format (ctrl)+(shift)+(alt)+[key]\",\n            \"event.toggleResultPane\": \"ctrl+alt+R\",\n            \"event.focusResultsGrid\": \"ctrl+alt+G\",\n            \"event.toggleMessagePane\": \"ctrl+alt+Y\",\n            \"event.prevGrid\": \"ctrl+up\",\n            \"event.nextGrid\": \"ctrl+down\",\n            \"event.copySelection\": \"ctrl+C\",\n            \"event.copyWithHeaders\": \"\",\n            \"event.copyAllHeaders\": \"\",\n            \"event.maximizeGrid\": \"\",\n            \"event.selectAll\": \"ctrl+A\",\n            \"event.saveAsJSON\": \"\",\n            \"event.saveAsCSV\": \"\",\n            \"event.saveAsExcel\": \"\"\n        },\n        \"messagesDefaultOpen\": true,\n        \"resultsFontFamily\": \"-apple-system,BlinkMacSystemFont,Segoe WPC,Segoe UI,HelveticaNeue-Light,Ubuntu,Droid Sans,sans-serif\",\n        \"resultsFontSize\": 13,\n        \"saveAsCsv\": {\n            \"includeHeaders\": true,\n            \"delimiter\": \",\",\n            \"lineSeparator\": null,\n            \"textIdentifier\": \"\\\"\",\n            \"encoding\": \"utf-8\"\n        },\n        \"copyIncludeHeaders\": false,\n        \"copyRemoveNewLine\": true,\n        \"showBatchTime\": false,\n        \"splitPaneSelection\": \"next\",\n        \"format\": {\n            \"alignColumnDefinitionsInColumns\": false,\n            \"datatypeCasing\": \"none\",\n            \"keywordCasing\": \"none\",\n            \"placeCommasBeforeNextStatement\": false,\n            \"placeSelectStatementReferencesOnNewLine\": false\n        },\n        \"applyLocalization\": false,\n        \"query\": {\n            \"displayBitAsNumber\": true\n        },\n        \"intelliSense\": {\n            \"enableIntelliSense\": true,\n            \"enableErrorChecking\": true,\n            \"enableSuggestions\": true,\n            \"enableQuickInfo\": true,\n            \"lowerCaseSuggestions\": false\n        },\n        \"persistQueryResultTabs\": false\n    }\n}\n"
                                                                                 :object-type 'hash-table
                                                                                 :null-object nil
                                                                                 :false-object :json-false))))
                  ))


(defun lsp-mssql--expand-completed (workspace params)
  (-let [(&hash "sessionId" session-id "nodePath" node-path "nodes") params]
    (puthash (cons node-path nil)
             (append nodes nil)
             (gethash "explorer" (lsp--workspace-metadata workspace)) )
    (lsp-mssql-object-explorer)))

(defun lsp-mssql--session-created (workspace params)
  (-let [(&hash "rootNode" root-node "sessionId" session-id) params]
    (puthash (cons session-id t)
             (list root-node)
             (gethash "explorer" (lsp--workspace-metadata workspace)) )))


(defun lsp-mssql--to-node (nodes node)
  (-let [(&hash "label" "nodeType" node-type "nodePath" node-path "isLeaf" leaf?) node]
    `(:label ,label
             :key ,label
             :icon ,(intern node-type)
             ,@(unless leaf?
                 (list :children (lambda (node)
                                   (let ((children (gethash (list node-path) nodes :empty)))
                                     (if (not (eq :empty children))
                                         (-map (-partial #'lsp-mssql--to-node nodes) children)
                                       (ignore
                                        (with-current-buffer "sql.sql"
                                          (lsp-request "objectexplorer/expand"
                                                       `(:sessionId "localhost__SA_SqlLogin" :nodePath ,node-path))))))))))))

(defun lsp-mssql-object-explorer ()
  (interactive)
  (lsp-treemacs--show-references
   (let ((nodes (->> (lsp-find-workspace 'sql nil) lsp--workspace-metadata (gethash "explorer"))))
     (->> nodes
          ht->alist
          (-keep (-lambda (((id . is-session?) . node))
                   (when is-session? node)))
          -flatten
          (-map (-partial #'lsp-mssql--to-node nodes))))
   "XX"
   nil))


;; (-map 's-dashed-words  (-map 'f-base (-map 'f-filename (f-files "images"))))
;; (-map (lambda (f)
;; (treemacs-get-icon-value 'Server)
;;         `(treemacs-create-icon :file ,(f-filename f) :extensions (,(intern (f-base f))) :fallback "-"))
;;       (f-files "images"))

;; (treemacs-create-icon :file "BooleanData.png" :extensions (boolean-data) :fallback "-")
(with-current-buffer "sql.sql"
  (lsp-request "connection/connect"
               (json-parse-string "{\"ownerUri\":\"file:///home/kyoncho/Sources/java-tick42-config-services/src/test/java/com/tick42/fdc3/converter/sql.sql\",\"connection\":{\"options\":{\"server\":\"localhost\",\"database\":\"\",\"user\":\"SA\",\"password\":\"demoPWD2#\",\"authenticationType\":\"SqlLogin\",\"encrypt\":false,\"connectTimeout\":15,\"applicationName\":\"vscode-mssql\"}}}"
                                  :object-type 'hash-table
                                  :null-object nil
                                  :false-object :json-false)))

;; ;; {"jsonrpc":"2.0","id":11,"method":"connection/connect","params":
;; docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=demoPWD2" \
;;    -p 1433:1433 --name sql1 \
;;    -d mcr.microsoft.com/mssql/server:2019-GA-ubuntu-16.04

;; # !/bin/bash
;; bash -c "tee /tmp/sql-sending | /home/kyoncho/.vscode/extensions/ms-mssql.mssql-1.7.1/sqltoolsservice/1.7.1/Ubuntu16/MicrosoftSqlToolsServiceLayer-backup 2> rls-error | tee -a /tmp/sql-receiving"

(with-current-buffer "sql.sql"
  (lsp-request "objectexplorer/createsession"
               #s(hash-table size 1 test equal rehash-size 1.5 rehash-threshold 0.8125 data
                             ("options" #s(hash-table size 5 test equal rehash-size 1.5 rehash-threshold 0.8125 data
                                                      ("server" "localhost" "database" "" "user" "SA" "password" "demoPWD2#" "authenticationType" "SqlLogin"))))))

(with-current-buffer "sql.sql"
  (lsp-request "objectexplorer/expand"
               '(:sessionId "localhost__SA_SqlLogin" :nodePath "localhost")))

(with-current-buffer "sql.sql"
  (lsp-request "query/executeDocumentSelection"
               `(:ownerUri "file:///home/kyoncho/Sources/java-tick42-config-services/src/test/java/com/tick42/fdc3/converter/sql.sql"
                           :querySelection ,(lsp--range (point-min)
                                                        (point-max)))))
