Table of contents
* [Global options](#global-options)
  * [from](#from)
  * [grafana_default_dashboard](#grafana_default_dashboard)
  * [grafana_default_from_timezone](#grafana_default_from_timezone)
  * [grafana_default_instance](#grafana_default_instance)
  * [grafana_default_to_timezone](#grafana_default_to_timezone)
  * [to](#to)
* [Functions](#functions)
  * [grafana_alerts](#grafana_alerts)
  * [grafana_annotations](#grafana_annotations)
  * [grafana_environment](#grafana_environment)
  * [grafana_help](#grafana_help)
  * [grafana_panel_image](#grafana_panel_image)
  * [grafana_panel_property](#grafana_panel_property)
  * [grafana_panel_query_table](#grafana_panel_query_table)
  * [grafana_panel_query_value](#grafana_panel_query_value)
  * [grafana_sql_table](#grafana_sql_table)
  * [grafana_sql_value](#grafana_sql_value)
  * [grafana_value_as_variable](#grafana_value_as_variable)

## Global options

### `from`
Usage: `:from: <from_timestamp>`

Overrides the time setting from grafana. It may contain dates as `now-1M/M`, which will be translated properly to timestamps relative to the called time.

### `grafana_default_dashboard`
Usage: `:grafana_default_dashboard: <dashboard_uid>`

Specifies to which dashboard the queries shall be targeted by default.

### `grafana_default_from_timezone`
Usage: `:grafana_default_from_timezone: <timezone>`

Specifies which timezone shall be used for the `from` time, e.g. `CET` or `CEST`.

### `grafana_default_instance`
Usage: `:grafana_default_instance: <instance_name>`

Specifies which grafana instance shall be used. If not set, the grafana instance names `default` will be used.

### `grafana_default_to_timezone`
Usage: `:grafana_default_to_timezone: <timezone>`

Specifies which timezone shall be used for the `to` time, e.g. `CET` or `CEST`.

### `to`
Usage: `:to: <to_timestamp>`

Overrides the time setting from grafana. It may contain dates as `now-1M/M`, which will be translated properly to timestamps relative to the called time.

## Functions

### `grafana_alerts`
Usage: `include::grafana_alerts[columns="<column_name_1>,<column_name_2>,...",options]`

Returns a table of active alert states including the specified columns and the connected information. Supports all query parameters from the Grafana Alerting API, such as `query`, `state`, `limit`, `folderId` and others.

See also: https://grafana.com/docs/grafana/latest/http_api/alerting/#get-alerts

| Option | Description
| -- | -- 
| `after_calculate="<action_1>,<action_2>,..."` | Specify the actions, that shall be performed after the query calculations have been finished, i.e. after `select_value` calculations have been performed. Possible values are: `format`, `replace_values`, `filter_columns`, `transpose` and `transpose!`. `transpose!` enforces a transposition of the table, independent from the configuration `transpose="true"`, which can specifically be useful, if a table is being transposed twice. Default: `format,replace_values,transpose`
| `after_fetch="<action_1>,<action_2>,..."` | Specify the actions, that shall be performed after the query data has been fetched (and before `select_value` calculations are performed). Possible values are: `format`, `replace_values`, `filter_columns`, `transpose` and `transpose!`. `transpose!` enforces a transposition of the table, independent from the configuration `transpose="true"`, which can specifically be useful, if a table is being transposed twice. Default: `filter_columns`
| `column_divider="<divider>"` | Replace the default column divider with another one, when used in conjunction with `table_formatter` set to `adoc_deprecated`. Defaults to ` \| ` for being interpreted as a asciidoctor column. Note that this option is DEPRECATED. As a replacement,  switch to `table_formatter` named `adoc_plain`, or implement a custom table formatter.
| `columns="<column_name_1>,<columns_name_2>,..."` | Specifies columns that shall be returned. Valid columns are `id`, `dashboardId`, `dashboardUId`, `dashboardSlug`, `panelId`, `name`, `state`, `newStateDate`, `evalDate`, `evalData` and `executionError`.
| `dashboard="<dashboard_uid>"` | Specifies the dashboard to be used. If `grafana_default_dashboard` is specified in the report template, this value can be overridden with this option. If this option, or the global option `grafana_default_dashboard` is set, the resulting alerts will be limited to this dashboard. To show all alerts in this case, specify `dashboard=""` as option
| `filter_columns="<column_name_1>,<column_name_2>,..."` | Removes specified columns from result.  Commas in format strings are supported, but have to be escaped by using `_,`.
| `format="<format_col1>,<format_col2>,..."` | Specify format in which the results in a specific column shall be returned, e.g. `%.2f` for only two digit decimals of a float. Several column formats are separated by `,`, i.e. `%.2f,%.3f` would apply `%.2f` to the first column and `%.3f` to the second column. All other columns would not be formatted. You may also format time in milliseconds to a time format by specifying e.g. `date:iso`. Commas in format strings are supported, but have to be escaped by using `_,`.<br />See also: https://ruby-doc.org/core/Kernel.html#method-i-sprintf
| `from="<timestamp>"` | can be used to override default `from` time
| `from_timezone="<timezone>"` | can be used to override system timezone for `from` time and will also override `grafana_default_from_timezone` option
| `include_headline="true"` | Adds the headline of the columns as first row of the resulting table.
| `instance="<instance_name>"` | can be used to override global grafana instance, set in the report with `grafana_default_instance`. If nothing is set, the configured grafana instance with name `default` will be used.
| `panel="<panel_id>"` | If specified, the resulting alerts are filtered for this panel. This option will only work, if a `dashboard` or `grafana_default_dashboard` is set.
| `replace_values="<replace_1>:<with_1>,<replace_2>:<with_2>,..."` | Specify result values which shall be replaced, e.g. `2:OK` will replace query values `2` with value `OK`. Replacing several values is possible by separating by `,`. Matches with regular expressions are also supported, but must be full matches, i.e. have to start with `^` and end with `$`, e.g. `^[012]$:OK`. Number replacements can also be performed, e.g. `<8.2` or `<>3`.<br />See also: https://ruby-doc.org/core/Regexp.html#class-Regexp-label-Character+Classes
| `row_divider="<divider>"` | Replace the default row divider with another one, when used in conjunction with `table_formatter` set to `adoc_deprecated`. Defaults to `\| ` for being interpreted as a asciidoctor row. Note that this option is DEPRECATED. As a replacement, switch to `table_formatter` named `adoc_plain`, or implement a custom table formatter.
| `table_formatter="<formatter>"` | Specify a table formatter fitting for your expected target format. It defaults to `adoc_plain` for asciidoctor templates and to `csv` for all other templates, e.g. ERB.
| `timeout="<timeout_in_seconds>"` | Set a timeout for the current query. If not overridden with `grafana_default_timeout` in the report template, this defaults to 60 seconds.
| `to="<timestamp>"` | can be used to override default `to` time
| `to_timezone="<timezone>"` | can be used to override system timezone for `to` time and will also override `grafana_default_to_timezone` option
| `transpose="true"` | Transposes the query result, i.e. columns become rows and rows become columnns.

### `grafana_annotations`
Usage: `include::grafana_annotations[columns="<column_name_1>,<column_name_2>,...",options]`

Returns a table of all annotations, matching the specified filter criteria and the specified columns. Supports all query parameters from the Grafana Alerting API, such as `limit`, `alertId`, `panelId` and others.

See also: https://grafana.com/docs/grafana/latest/http_api/annotations/#find-annotations

| Option | Description
| -- | -- 
| `after_calculate="<action_1>,<action_2>,..."` | Specify the actions, that shall be performed after the query calculations have been finished, i.e. after `select_value` calculations have been performed. Possible values are: `format`, `replace_values`, `filter_columns`, `transpose` and `transpose!`. `transpose!` enforces a transposition of the table, independent from the configuration `transpose="true"`, which can specifically be useful, if a table is being transposed twice. Default: `format,replace_values,transpose`
| `after_fetch="<action_1>,<action_2>,..."` | Specify the actions, that shall be performed after the query data has been fetched (and before `select_value` calculations are performed). Possible values are: `format`, `replace_values`, `filter_columns`, `transpose` and `transpose!`. `transpose!` enforces a transposition of the table, independent from the configuration `transpose="true"`, which can specifically be useful, if a table is being transposed twice. Default: `filter_columns`
| `column_divider="<divider>"` | Replace the default column divider with another one, when used in conjunction with `table_formatter` set to `adoc_deprecated`. Defaults to ` \| ` for being interpreted as a asciidoctor column. Note that this option is DEPRECATED. As a replacement,  switch to `table_formatter` named `adoc_plain`, or implement a custom table formatter.
| `columns="<column_name_1>,<columns_name_2>,..."` | Specified the columns that shall be returned. Valid columns are `id`, `alertId`, `dashboardId`, `panelId`, `userId`, `userName`, `newState`, `prevState`, `time`, `timeEnd`, `text`, `metric` and `type`.
| `dashboard="<dashboard_uid>"` | Specifies the dashboard to be used. If `grafana_default_dashboard` is specified in the report template, this value can be overridden with this option. If this option, or the global option `grafana_default_dashboard` is set, the resulting alerts will be limited to this dashboard. To show all alerts in this case, specify `dashboard=""` as option
| `filter_columns="<column_name_1>,<column_name_2>,..."` | Removes specified columns from result.  Commas in format strings are supported, but have to be escaped by using `_,`.
| `format="<format_col1>,<format_col2>,..."` | Specify format in which the results in a specific column shall be returned, e.g. `%.2f` for only two digit decimals of a float. Several column formats are separated by `,`, i.e. `%.2f,%.3f` would apply `%.2f` to the first column and `%.3f` to the second column. All other columns would not be formatted. You may also format time in milliseconds to a time format by specifying e.g. `date:iso`. Commas in format strings are supported, but have to be escaped by using `_,`.<br />See also: https://ruby-doc.org/core/Kernel.html#method-i-sprintf
| `from="<timestamp>"` | can be used to override default `from` time
| `from_timezone="<timezone>"` | can be used to override system timezone for `from` time and will also override `grafana_default_from_timezone` option
| `include_headline="true"` | Adds the headline of the columns as first row of the resulting table.
| `instance="<instance_name>"` | can be used to override global grafana instance, set in the report with `grafana_default_instance`. If nothing is set, the configured grafana instance with name `default` will be used.
| `panel="<panel_id>"` | If specified, the resulting alerts are filtered for this panel. This option will only work, if a `dashboard` or `grafana_default_dashboard` is set.
| `replace_values="<replace_1>:<with_1>,<replace_2>:<with_2>,..."` | Specify result values which shall be replaced, e.g. `2:OK` will replace query values `2` with value `OK`. Replacing several values is possible by separating by `,`. Matches with regular expressions are also supported, but must be full matches, i.e. have to start with `^` and end with `$`, e.g. `^[012]$:OK`. Number replacements can also be performed, e.g. `<8.2` or `<>3`.<br />See also: https://ruby-doc.org/core/Regexp.html#class-Regexp-label-Character+Classes
| `row_divider="<divider>"` | Replace the default row divider with another one, when used in conjunction with `table_formatter` set to `adoc_deprecated`. Defaults to `\| ` for being interpreted as a asciidoctor row. Note that this option is DEPRECATED. As a replacement, switch to `table_formatter` named `adoc_plain`, or implement a custom table formatter.
| `table_formatter="<formatter>"` | Specify a table formatter fitting for your expected target format. It defaults to `adoc_plain` for asciidoctor templates and to `csv` for all other templates, e.g. ERB.
| `timeout="<timeout_in_seconds>"` | Set a timeout for the current query. If not overridden with `grafana_default_timeout` in the report template, this defaults to 60 seconds.
| `to="<timestamp>"` | can be used to override default `to` time
| `to_timezone="<timezone>"` | can be used to override system timezone for `to` time and will also override `grafana_default_to_timezone` option
| `transpose="true"` | Transposes the query result, i.e. columns become rows and rows become columnns.

### `grafana_environment`
Usage: `include::grafana_environment[]`

Shows all available variables in the rendering context which can be used in the asciidoctor template. If optional `instance` is specified, additional information about the configured grafana instance will be provided. This is especially helpful for debugging.

| Option | Description
| -- | -- 
| `instance="<instance_name>"` | can be used to override global grafana instance, set in the report with `grafana_default_instance`. If nothing is set, the configured grafana instance with name `default` will be used.

### `grafana_help`
Usage: `include::grafana_help[]`

Show all available grafana calls within the asciidoctor templates, including available options.

### `grafana_panel_image`
Usage: `grafana_panel_image:<panel_id>[options] or grafana_panel_image::<panel_id>[options]`

Includes a panel image as an image in the document. Can be called for inline-images as well as for blocks.

| Option | Description
| -- | -- 
| `dashboard="<dashboard_uid>"` | Specifies the dashboard to be used. If `grafana_default_dashboard` is specified in the report template, this value can be overridden with this option.
| `from="<timestamp>"` | can be used to override default `from` time
| `from_timezone="<timezone>"` | can be used to override system timezone for `from` time and will also override `grafana_default_from_timezone` option
| `instance="<instance_name>"` | can be used to override global grafana instance, set in the report with `grafana_default_instance`. If nothing is set, the configured grafana instance with name `default` will be used.
| `render-height="<height>"` | can be used to override default `height` in which the panel shall be rendered
| `render-scale="<scale>"` | can be used to override default scale in which the panel shall be rendered
| `render-theme="<theme>"` | can be used to override default `theme` in which the panel shall be rendered (light by default)
| `render-timeout="<timeout>"` | can be used to override default `timeout` in which the panel shall be rendered (60 seconds by default)
| `render-width="<width>"` | can be used to override default `width` in which the panel shall be rendered
| `timeout="<timeout_in_seconds>"` | Set a timeout for the current query. If not overridden with `grafana_default_timeout` in the report template, this defaults to 60 seconds.
| `to="<timestamp>"` | can be used to override default `to` time
| `to_timezone="<timezone>"` | can be used to override system timezone for `to` time and will also override `grafana_default_to_timezone` option

### `grafana_panel_property`
Usage: `grafana_panel_property:<panel_id>["<type>",options]`

Returns a property field for the specified panel. `<type>` can either be `title` or `description`. Grafana variables will be replaced in the returned value.

See also: https://grafana.com/docs/grafana/latest/variables/syntax/

| Option | Description
| -- | -- 
| `dashboard="<dashboard_uid>"` | Specifies the dashboard to be used. If `grafana_default_dashboard` is specified in the report template, this value can be overridden with this option.
| `instance="<instance_name>"` | can be used to override global grafana instance, set in the report with `grafana_default_instance`. If nothing is set, the configured grafana instance with name `default` will be used.

### `grafana_panel_query_table`
Usage: `include::grafana_panel_query_table:<panel_id>[query="<query_letter>",options]`

Returns the results of a query, which is configured in a grafana panel, as a table in asciidoctor. Grafana variables will be replaced in the panel's SQL statement.

See also: https://grafana.com/docs/grafana/latest/variables/syntax/

| Option | Description
| -- | -- 
| `after_calculate="<action_1>,<action_2>,..."` | Specify the actions, that shall be performed after the query calculations have been finished, i.e. after `select_value` calculations have been performed. Possible values are: `format`, `replace_values`, `filter_columns`, `transpose` and `transpose!`. `transpose!` enforces a transposition of the table, independent from the configuration `transpose="true"`, which can specifically be useful, if a table is being transposed twice. Default: `format,replace_values,transpose`
| `after_fetch="<action_1>,<action_2>,..."` | Specify the actions, that shall be performed after the query data has been fetched (and before `select_value` calculations are performed). Possible values are: `format`, `replace_values`, `filter_columns`, `transpose` and `transpose!`. `transpose!` enforces a transposition of the table, independent from the configuration `transpose="true"`, which can specifically be useful, if a table is being transposed twice. Default: `filter_columns`
| `column_divider="<divider>"` | Replace the default column divider with another one, when used in conjunction with `table_formatter` set to `adoc_deprecated`. Defaults to ` \| ` for being interpreted as a asciidoctor column. Note that this option is DEPRECATED. As a replacement,  switch to `table_formatter` named `adoc_plain`, or implement a custom table formatter.
| `dashboard="<dashboard_uid>"` | Specifies the dashboard to be used. If `grafana_default_dashboard` is specified in the report template, this value can be overridden with this option.
| `filter_columns="<column_name_1>,<column_name_2>,..."` | Removes specified columns from result.  Commas in format strings are supported, but have to be escaped by using `_,`.
| `format="<format_col1>,<format_col2>,..."` | Specify format in which the results in a specific column shall be returned, e.g. `%.2f` for only two digit decimals of a float. Several column formats are separated by `,`, i.e. `%.2f,%.3f` would apply `%.2f` to the first column and `%.3f` to the second column. All other columns would not be formatted. You may also format time in milliseconds to a time format by specifying e.g. `date:iso`. Commas in format strings are supported, but have to be escaped by using `_,`.<br />See also: https://ruby-doc.org/core/Kernel.html#method-i-sprintf
| `from="<timestamp>"` | can be used to override default `from` time
| `from_timezone="<timezone>"` | can be used to override system timezone for `from` time and will also override `grafana_default_from_timezone` option
| `include_headline="true"` | Adds the headline of the columns as first row of the resulting table.
| `instance="<instance_name>"` | can be used to override global grafana instance, set in the report with `grafana_default_instance`. If nothing is set, the configured grafana instance with name `default` will be used.
| `instant="true"` | Optional parameter for Prometheus `instant` queries. Ignored for other datasources than Prometheus.
| `interval="<intervaL>"` | Used to set the interval size for timescale datasources, whereas the value is used without further conversion directly in the datasource specific interval parameter. Prometheus default: 15 (passed as `step` parameter) Influx default: similar to grafana default, i.e. `(to_time - from_time) / 1000` (replaces `interval_ms` and `interval` variables in query)
| `query="<query_letter>"` | +<query_letter>+ needs to point to the grafana query which shall be evaluated, e.g. +A+ or +B+.
| `replace_values="<replace_1>:<with_1>,<replace_2>:<with_2>,..."` | Specify result values which shall be replaced, e.g. `2:OK` will replace query values `2` with value `OK`. Replacing several values is possible by separating by `,`. Matches with regular expressions are also supported, but must be full matches, i.e. have to start with `^` and end with `$`, e.g. `^[012]$:OK`. Number replacements can also be performed, e.g. `<8.2` or `<>3`.<br />See also: https://ruby-doc.org/core/Regexp.html#class-Regexp-label-Character+Classes
| `row_divider="<divider>"` | Replace the default row divider with another one, when used in conjunction with `table_formatter` set to `adoc_deprecated`. Defaults to `\| ` for being interpreted as a asciidoctor row. Note that this option is DEPRECATED. As a replacement, switch to `table_formatter` named `adoc_plain`, or implement a custom table formatter.
| `table_formatter="<formatter>"` | Specify a table formatter fitting for your expected target format. It defaults to `adoc_plain` for asciidoctor templates and to `csv` for all other templates, e.g. ERB.
| `timeout="<timeout_in_seconds>"` | Set a timeout for the current query. If not overridden with `grafana_default_timeout` in the report template, this defaults to 60 seconds.
| `to="<timestamp>"` | can be used to override default `to` time
| `to_timezone="<timezone>"` | can be used to override system timezone for `to` time and will also override `grafana_default_to_timezone` option
| `transpose="true"` | Transposes the query result, i.e. columns become rows and rows become columnns.
| `verbose_log="true"` | Setting this option will show additional information about the returned query results in the log as DEBUG messages.

### `grafana_panel_query_value`
Usage: `grafana_panel_query_value:<panel_id>[query="<query_letter>",options]`

Returns the value in the first column and the first row of a query, which is configured in a grafana panel. Grafana variables will be replaced in the panel's SQL statement.

See also: https://grafana.com/docs/grafana/latest/variables/syntax/

| Option | Description
| -- | -- 
| `after_calculate="<action_1>,<action_2>,..."` | Specify the actions, that shall be performed after the query calculations have been finished, i.e. after `select_value` calculations have been performed. Possible values are: `format`, `replace_values`, `filter_columns`, `transpose` and `transpose!`. `transpose!` enforces a transposition of the table, independent from the configuration `transpose="true"`, which can specifically be useful, if a table is being transposed twice. Default: `format,replace_values,transpose`
| `after_fetch="<action_1>,<action_2>,..."` | Specify the actions, that shall be performed after the query data has been fetched (and before `select_value` calculations are performed). Possible values are: `format`, `replace_values`, `filter_columns`, `transpose` and `transpose!`. `transpose!` enforces a transposition of the table, independent from the configuration `transpose="true"`, which can specifically be useful, if a table is being transposed twice. Default: `filter_columns`
| `dashboard="<dashboard_uid>"` | Specifies the dashboard to be used. If `grafana_default_dashboard` is specified in the report template, this value can be overridden with this option.
| `filter_columns="<column_name_1>,<column_name_2>,..."` | Removes specified columns from result.  Commas in format strings are supported, but have to be escaped by using `_,`.
| `format="<format_col1>,<format_col2>,..."` | Specify format in which the results in a specific column shall be returned, e.g. `%.2f` for only two digit decimals of a float. Several column formats are separated by `,`, i.e. `%.2f,%.3f` would apply `%.2f` to the first column and `%.3f` to the second column. All other columns would not be formatted. You may also format time in milliseconds to a time format by specifying e.g. `date:iso`. Commas in format strings are supported, but have to be escaped by using `_,`.<br />See also: https://ruby-doc.org/core/Kernel.html#method-i-sprintf
| `from="<timestamp>"` | can be used to override default `from` time
| `from_timezone="<timezone>"` | can be used to override system timezone for `from` time and will also override `grafana_default_from_timezone` option
| `instance="<instance_name>"` | can be used to override global grafana instance, set in the report with `grafana_default_instance`. If nothing is set, the configured grafana instance with name `default` will be used.
| `instant="true"` | Optional parameter for Prometheus `instant` queries. Ignored for other datasources than Prometheus.
| `interval="<intervaL>"` | Used to set the interval size for timescale datasources, whereas the value is used without further conversion directly in the datasource specific interval parameter. Prometheus default: 15 (passed as `step` parameter) Influx default: similar to grafana default, i.e. `(to_time - from_time) / 1000` (replaces `interval_ms` and `interval` variables in query)
| `query="<query_letter>"` | +<query_letter>+ needs to point to the grafana query which shall be evaluated, e.g. +A+ or +B+.
| `replace_values="<replace_1>:<with_1>,<replace_2>:<with_2>,..."` | Specify result values which shall be replaced, e.g. `2:OK` will replace query values `2` with value `OK`. Replacing several values is possible by separating by `,`. Matches with regular expressions are also supported, but must be full matches, i.e. have to start with `^` and end with `$`, e.g. `^[012]$:OK`. Number replacements can also be performed, e.g. `<8.2` or `<>3`.<br />See also: https://ruby-doc.org/core/Regexp.html#class-Regexp-label-Character+Classes
| `select_value="<select_value>"` | Allows the selection of a specific value from the result set.  Supported options are `min`, `max`, `avg`, `sum`, `first`, `last`.
| `timeout="<timeout_in_seconds>"` | Set a timeout for the current query. If not overridden with `grafana_default_timeout` in the report template, this defaults to 60 seconds.
| `to="<timestamp>"` | can be used to override default `to` time
| `to_timezone="<timezone>"` | can be used to override system timezone for `to` time and will also override `grafana_default_to_timezone` option
| `verbose_log="true"` | Setting this option will show additional information about the returned query results in the log as DEBUG messages.

### `grafana_sql_table`
Usage: `include::grafana_sql_table:<datasource_id>[sql="<sql_query>",options]`

Returns a table with all results of the given query. Grafana variables will be replaced in the SQL statement.

See also: https://grafana.com/docs/grafana/latest/variables/syntax/

| Option | Description
| -- | -- 
| `after_calculate="<action_1>,<action_2>,..."` | Specify the actions, that shall be performed after the query calculations have been finished, i.e. after `select_value` calculations have been performed. Possible values are: `format`, `replace_values`, `filter_columns`, `transpose` and `transpose!`. `transpose!` enforces a transposition of the table, independent from the configuration `transpose="true"`, which can specifically be useful, if a table is being transposed twice. Default: `format,replace_values,transpose`
| `after_fetch="<action_1>,<action_2>,..."` | Specify the actions, that shall be performed after the query data has been fetched (and before `select_value` calculations are performed). Possible values are: `format`, `replace_values`, `filter_columns`, `transpose` and `transpose!`. `transpose!` enforces a transposition of the table, independent from the configuration `transpose="true"`, which can specifically be useful, if a table is being transposed twice. Default: `filter_columns`
| `column_divider="<divider>"` | Replace the default column divider with another one, when used in conjunction with `table_formatter` set to `adoc_deprecated`. Defaults to ` \| ` for being interpreted as a asciidoctor column. Note that this option is DEPRECATED. As a replacement,  switch to `table_formatter` named `adoc_plain`, or implement a custom table formatter.
| `filter_columns="<column_name_1>,<column_name_2>,..."` | Removes specified columns from result.  Commas in format strings are supported, but have to be escaped by using `_,`.
| `format="<format_col1>,<format_col2>,..."` | Specify format in which the results in a specific column shall be returned, e.g. `%.2f` for only two digit decimals of a float. Several column formats are separated by `,`, i.e. `%.2f,%.3f` would apply `%.2f` to the first column and `%.3f` to the second column. All other columns would not be formatted. You may also format time in milliseconds to a time format by specifying e.g. `date:iso`. Commas in format strings are supported, but have to be escaped by using `_,`.<br />See also: https://ruby-doc.org/core/Kernel.html#method-i-sprintf
| `from="<timestamp>"` | can be used to override default `from` time
| `from_timezone="<timezone>"` | can be used to override system timezone for `from` time and will also override `grafana_default_from_timezone` option
| `include_headline="true"` | Adds the headline of the columns as first row of the resulting table.
| `instance="<instance_name>"` | can be used to override global grafana instance, set in the report with `grafana_default_instance`. If nothing is set, the configured grafana instance with name `default` will be used.
| `instant="true"` | Optional parameter for Prometheus `instant` queries. Ignored for other datasources than Prometheus.
| `interval="<intervaL>"` | Used to set the interval size for timescale datasources, whereas the value is used without further conversion directly in the datasource specific interval parameter. Prometheus default: 15 (passed as `step` parameter) Influx default: similar to grafana default, i.e. `(to_time - from_time) / 1000` (replaces `interval_ms` and `interval` variables in query)
| `replace_values="<replace_1>:<with_1>,<replace_2>:<with_2>,..."` | Specify result values which shall be replaced, e.g. `2:OK` will replace query values `2` with value `OK`. Replacing several values is possible by separating by `,`. Matches with regular expressions are also supported, but must be full matches, i.e. have to start with `^` and end with `$`, e.g. `^[012]$:OK`. Number replacements can also be performed, e.g. `<8.2` or `<>3`.<br />See also: https://ruby-doc.org/core/Regexp.html#class-Regexp-label-Character+Classes
| `row_divider="<divider>"` | Replace the default row divider with another one, when used in conjunction with `table_formatter` set to `adoc_deprecated`. Defaults to `\| ` for being interpreted as a asciidoctor row. Note that this option is DEPRECATED. As a replacement, switch to `table_formatter` named `adoc_plain`, or implement a custom table formatter.
| `table_formatter="<formatter>"` | Specify a table formatter fitting for your expected target format. It defaults to `adoc_plain` for asciidoctor templates and to `csv` for all other templates, e.g. ERB.
| `timeout="<timeout_in_seconds>"` | Set a timeout for the current query. If not overridden with `grafana_default_timeout` in the report template, this defaults to 60 seconds.
| `to="<timestamp>"` | can be used to override default `to` time
| `to_timezone="<timezone>"` | can be used to override system timezone for `to` time and will also override `grafana_default_to_timezone` option
| `transpose="true"` | Transposes the query result, i.e. columns become rows and rows become columnns.
| `verbose_log="true"` | Setting this option will show additional information about the returned query results in the log as DEBUG messages.

### `grafana_sql_value`
Usage: `grafana_sql_value:<datasource_id>[sql="<sql_query>",options]`

Returns the value in the first column and the first row of the given query. Grafana variables will be replaced in the SQL statement.
Please note that asciidoctor might fail, if you use square brackets in your sql statement. To overcome this issue, you'll need to escape the closing square brackets, i.e. +]+ needs to be replaced with +\]+.

See also: https://grafana.com/docs/grafana/latest/variables/syntax/

| Option | Description
| -- | -- 
| `after_calculate="<action_1>,<action_2>,..."` | Specify the actions, that shall be performed after the query calculations have been finished, i.e. after `select_value` calculations have been performed. Possible values are: `format`, `replace_values`, `filter_columns`, `transpose` and `transpose!`. `transpose!` enforces a transposition of the table, independent from the configuration `transpose="true"`, which can specifically be useful, if a table is being transposed twice. Default: `format,replace_values,transpose`
| `after_fetch="<action_1>,<action_2>,..."` | Specify the actions, that shall be performed after the query data has been fetched (and before `select_value` calculations are performed). Possible values are: `format`, `replace_values`, `filter_columns`, `transpose` and `transpose!`. `transpose!` enforces a transposition of the table, independent from the configuration `transpose="true"`, which can specifically be useful, if a table is being transposed twice. Default: `filter_columns`
| `filter_columns="<column_name_1>,<column_name_2>,..."` | Removes specified columns from result.  Commas in format strings are supported, but have to be escaped by using `_,`.
| `format="<format_col1>,<format_col2>,..."` | Specify format in which the results in a specific column shall be returned, e.g. `%.2f` for only two digit decimals of a float. Several column formats are separated by `,`, i.e. `%.2f,%.3f` would apply `%.2f` to the first column and `%.3f` to the second column. All other columns would not be formatted. You may also format time in milliseconds to a time format by specifying e.g. `date:iso`. Commas in format strings are supported, but have to be escaped by using `_,`.<br />See also: https://ruby-doc.org/core/Kernel.html#method-i-sprintf
| `from="<timestamp>"` | can be used to override default `from` time
| `from_timezone="<timezone>"` | can be used to override system timezone for `from` time and will also override `grafana_default_from_timezone` option
| `instance="<instance_name>"` | can be used to override global grafana instance, set in the report with `grafana_default_instance`. If nothing is set, the configured grafana instance with name `default` will be used.
| `instant="true"` | Optional parameter for Prometheus `instant` queries. Ignored for other datasources than Prometheus.
| `interval="<intervaL>"` | Used to set the interval size for timescale datasources, whereas the value is used without further conversion directly in the datasource specific interval parameter. Prometheus default: 15 (passed as `step` parameter) Influx default: similar to grafana default, i.e. `(to_time - from_time) / 1000` (replaces `interval_ms` and `interval` variables in query)
| `replace_values="<replace_1>:<with_1>,<replace_2>:<with_2>,..."` | Specify result values which shall be replaced, e.g. `2:OK` will replace query values `2` with value `OK`. Replacing several values is possible by separating by `,`. Matches with regular expressions are also supported, but must be full matches, i.e. have to start with `^` and end with `$`, e.g. `^[012]$:OK`. Number replacements can also be performed, e.g. `<8.2` or `<>3`.<br />See also: https://ruby-doc.org/core/Regexp.html#class-Regexp-label-Character+Classes
| `select_value="<select_value>"` | Allows the selection of a specific value from the result set.  Supported options are `min`, `max`, `avg`, `sum`, `first`, `last`.
| `timeout="<timeout_in_seconds>"` | Set a timeout for the current query. If not overridden with `grafana_default_timeout` in the report template, this defaults to 60 seconds.
| `to="<timestamp>"` | can be used to override default `to` time
| `to_timezone="<timezone>"` | can be used to override system timezone for `to` time and will also override `grafana_default_to_timezone` option
| `verbose_log="true"` | Setting this option will show additional information about the returned query results in the log as DEBUG messages.

### `grafana_value_as_variable`
Usage: `include::grafana_value_as_variable[call="<grafana_reporter_call>",variable_name="<your_variable_name>",options]`

Executes the given +<grafana_reporter_call>+ and stored the resulting value in the given +<your_variable_name>+, so that it can be used in asciidoctor at any position with +{<your_variable_name>}+.
A sample call could look like this: +include:grafana_value_as_variable[call="grafana_sql_value:1",variable_name="my_variable",sql="SELECT 'looks good'",<any_other_option>]+
If the function succeeds, it will add this to the asciidoctor file:
+:my_variable: looks good+
Please note, that you may add any other option to the call. These will simply be passed 1:1 to the +<grafana_reporter_call>+.

| Option | Description
| -- | -- 
| `call="<grafana_reporter_call>"` | Call to grafana reporter function, for which the result shall be stored as variable. Please note that only functions without +include::+ are supported here.
| `variable_name="<your_variable_name>"` | Name of the variable, which will get the value assigned.
