#!/usr/bin/php
<?php

define('JIFFY_VERSION', '1.0');

// Ensure script runs only in CLI mode
if (php_sapi_name() !== "cli") {
    exit("JIFFY must be executed from the command line.\n");
}

// Define available commands
$commands = [
    "new" => "Create a new JIFFY project",
    "serve" => "Start local development server",
    "add" => "Generate a new route/page",
    "set-layout" => "Assign a layout to route",
    "set-meta" => "Inject metadata into a route",
    "cache-clear" => "Clear cached pages",
    "list-project" => "Show project structure",
    "list-routes" => "List all registered routes",
    "list-layouts" => "List available layouts",
    "list-meta" => "Show metadata for a route",
    "list-cache" => "Show cached pages",
    "list-logs" => "View system logs",
    "-v" => "Display JIFFY version",
    "-version" => "Display JIFFY version",
];

// Parse command-line arguments
if ($argc < 2) {
    echo "JIFFY CLI - A lightweight web tool\n";
    echo "Usage: jiffy [command] [options]\n\n";
    echo "Available commands:\n";
    foreach ($commands as $cmd => $desc) {
        echo "  $cmd - $desc\n";
    }
    exit;
}

$command = $argv[1];

switch ($command) {
    case "-v":
    case "-version":
        echo "JIFFY CLI Version " . JIFFY_VERSION . "\n";
        break;

    case "new":
        if (isset($argv[2])) {
            createProject($argv[2]);
        } else {
            echo "Usage: jiffy new [projectName]\n";
        }
        break;

    case "serve":
        startServer();
        break;

    case "add":
        if (isset($argv[2])) {
            createRoute($argv[2]);
        } else {
            echo "Usage: jiffy add [routeName]\n";
        }
        break;

    case "list-project":
        listProjectStructure();
        break;

    default:
        echo "Unknown command: $command\n";
        echo "Run `jiffy` to see available commands.\n";
}

function createProject($name) {
    echo "Creating new JIFFY project: $name...\n";
    mkdir($name);
    mkdir("$name/public");
