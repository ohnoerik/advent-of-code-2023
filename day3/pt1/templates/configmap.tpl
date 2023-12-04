{{- if .Values.renderSolutionAsConfigMap }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.output.name }}
data:
  AdventOfCodeSolution: {{- include "pt1.solution" . | trim | indent 1 }}
{{- end -}}