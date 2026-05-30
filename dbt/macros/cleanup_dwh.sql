-- Removes tables and views from the given run configuration
-- Usage in production:
--    dbt run-operation cleanup_dwh
-- To only see the commands that it is about to perform:
--    dbt run-operation cleanup_dwh --args '{"dry_run": True}'

{% macro cleanup_dwh(dry_run=False) %}
    {% if execute %}
        {% set current_models = {} %}

        {% set all_tables = graph.nodes.values() | selectattr("resource_type", "in", ["model", "seed", "snapshot"]) | list %}
        {% do all_tables.extend(graph.sources.values() | selectattr("resource_type", "equalto", "source" ) | list) %}
        
        {% for tab in all_tables %}
            {% if tab.schema not in current_models %}
                {% do current_models.update({tab.schema: []}) %}
            {% endif %}
            {% if tab.resource_type == "source" %}
                {% set table_name = tab.identifier %}
            {% else %}
                {% set table_name = tab.alias if tab.alias else tab.name %}
            {% endif %}
            {% do current_models[tab.schema].append(table_name) %}
        {% endfor %}
    {% endif %}

    {% set cleanup_query %}

        WITH models_to_drop AS (
            {% for schema, tables in current_models.items() if schema in ['default'] %} --!!!! REPLACE WITH SCHEMAS TO CLEANUP
                {% if not loop.first %} UNION ALL {% endif %}
                SELECT
                    database,
                    name AS table_name
                FROM system.tables
                WHERE database = '{{ schema }}'
                    AND name NOT IN ('{{ "', '".join(tables) }}')
            {% endfor %}
        )

        SELECT
            'DROP TABLE ' || database || '.' || table_name || ';' AS command
        FROM models_to_drop

    {% endset %}

    {% set drop_commands = run_query(cleanup_query) %}
    {% if drop_commands %}
        {% set drop_commands = drop_commands.columns[0].values() %}
        {% for drop_command in drop_commands %}
            {% do log(drop_command, True) %}
            {% if not dry_run | as_bool %}
                {% do run_query(drop_command) %}
            {% endif %}
        {% endfor %}
    {% else %}
        {% do log("No obsolete tables to clean.", True) %}
    {% endif %}
{% endmacro %}
