---@module "luassert"

local diff = require("arc.diff")

describe("diff.parse_hunk_header", function()
	local tests = {
		{
			name = "empty",
			input = "",
			expected = {
				prev = { start = nil, count = nil },
				now = { start = nil, count = nil },
			},
		},
		{
			name = "first",
			input = [[@@ -7 +7,3 @@ import _ from 'lodash';]],
			expected = {
				prev = { start = 7, count = 1 },
				now = { start = 7, count = 3 },
			},
		},
		{
			name = "second",
			input = [[@@ -8 +7,0 @@ import {DynamicList, type DynamicListProps} from '../../DynamicList/DynamicList']],
			expected = {
				prev = { start = 8, count = 1 },
				now = { start = 7, count = 0 },
			},
		},
		{
			name = "deletion hunk",
			input = [[@@ -10,5 +10,0 @@ function example() {]],
			expected = {
				prev = { start = 10, count = 5 },
				now = { start = 10, count = 0 },
			},
		},
		{
			name = "addition hunk",
			input = [[@@ -20,0 +20,4 @@ return {]],
			expected = {
				prev = { start = 20, count = 0 },
				now = { start = 20, count = 4 },
			},
		},
		{
			name = "replace hunk",
			input = [[@@ -30,2 +30,3 @@ class Test {]],
			expected = {
				prev = { start = 30, count = 2 },
				now = { start = 30, count = 3 },
			},
		},
		{
			name = "single line context",
			input = [[@@ -42 +42 @@ export default function() {]],
			expected = {
				prev = { start = 42, count = 1 },
				now = { start = 42, count = 1 },
			},
		},
		{
			name = "zero-length starting point",
			input = [[@@ -0,0 +1,10 @@ // New file content]],
			expected = {
				prev = { start = 0, count = 0 },
				now = { start = 1, count = 10 },
			},
		},
	}

	for _, test in ipairs(tests) do
		it("should parse " .. test.name, function()
			assert.are.same(test.expected, diff._parse_hunk_header(test.input))
		end)
	end
end)

describe("diff.parse", function()
	local tests = {
		{
			name = "empty",
			input = "",
			expected = {},
		},
		{
			name = "New file",
			input = [[diff --git a/new_file.js b/new_file.js
new file mode 100644
index 0000000..1f89c0d
--- /dev/null
+++ b/new_file.js
@@ -0,0 +1,5 @@
+// This is a new file
+function newFeature() {
+  return "Hello, world!";
+}
+export default newFeature;]],
			expected = {
				{ type = "a", lstart = 1, lend = 5 },
			},
		},
		{
			name = "Deleted file",
			input = [[diff --git a/removed_file.js b/removed_file.js
deleted file mode 100644
index 1234567..0000000
--- a/removed_file.js
+++ /dev/null
@@ -1,4 +0,0 @@
-// This file is being removed
-function oldFeature() {
-  console.log("Goodbye!");
-}]],
			expected = {
				{ type = "d", lstart = 0, lend = 0 },
			},
		},
		{
			name = "Complex changes",
			input = [[--- infra/idp/ui/src/ui/shared/components/Filters/schemas/ServiceSelectWithNestedSchema.tsx	(23410d74561bc6ed7f499a02d103e1b730048258)
+++ infra/idp/ui/src/ui/shared/components/Filters/schemas/ServiceSelectWithNestedSchema.tsx	(working tree)
@@ -5 +5,2 @@ import {sdk} from '@services/sdk';
-import {FiltersLabelSet, type LabelSchema} from '@yandex-data-ui/common';
+import {ActionButton, FiltersLabelSet, type LabelSchema} from '@yandex-data-ui/common';
+import {AppError} from '@yandex-data-ui/core';
@@ -19,0 +21,2 @@ export interface ServiceWithNestedValue {
+    hello: string;
+    world: string;
@@ -30,2 +32,0 @@ interface ServiceSelectSchemaWithNestedOptions<Cursor>
-    withNestedLabel?: string;
-    showControls?: boolean;
]],
			expected = {
				{ type = "m", lstart = 5, lend = 6 },
				{ type = "a", lstart = 21, lend = 22 },
				{ type = "d", lstart = 32, lend = 32 },
			},
		},
		{
			name = "Deleted more than added",
			input = [[--- infra/idp/ui/test.txt	(23410d74561bc6ed7f499a02d103e1b730048258)
+++ infra/idp/ui/test.txt	(working tree)
--- infra/idp/ui/src/ui/shared/components/Filters/schemas/ServiceSelectWithNestedSchema.tsx	(23410d74561bc6ed7f499a02d103e1b730048258)
+++ infra/idp/ui/src/ui/shared/components/Filters/schemas/ServiceSelectWithNestedSchema.tsx	(working tree)
@@ -3,3 +3,2 @@ import * as React from 'react';
-import {Flex, Switch, Text, spacing} from '@gravity-ui/uikit';
-import {sdk} from '@services/sdk';
-import {FiltersLabelSet, type LabelSchema} from '@yandex-data-ui/common';
+import {ActionButton, FiltersLabelSet, type LabelSchema} from '@yandex-data-ui/common';
+import {AppError} from '@yandex-data-ui/core';
@@ -19,0 +19,2 @@ export interface ServiceWithNestedValue {
+    hello: string;
+    world: string;
@@ -30,2 +30,0 @@ interface ServiceSelectSchemaWithNestedOptions<Cursor>
-    withNestedLabel?: string;
-    showControls?: boolean;
]],
			expected = {
				{ type = "m", lstart = 3, lend = 4 },
				{ type = "a", lstart = 19, lend = 20 },
				{ type = "d", lstart = 30, lend = 30 },
			},
		},
		{
			name = "Binary file",
			input = [[diff --git a/image.png b/image.png
new file mode 100644
index 0000000..c2adfe2
Binary files /dev/null and b/image.png differ]],
			expected = {},
		},
		{
			name = "Mode change only",
			input = [[diff --git a/script.sh b/script.sh
old mode 100644
new mode 100755]],
			expected = {},
		},
		{
			name = "Rename with changes",
			input = [[diff --git a/old_name.js b/new_name.js
similarity index 80%
rename from old_name.js
rename to new_name.js
index 1234567..9876543 100644
--- a/old_name.js
+++ b/new_name.js
@@ -5 +5 @@ import React from 'react';
-const oldName = 'Old';
+const newName = 'New';]],
			expected = {
				{ type = "m", lstart = 5, lend = 5 },
			},
		},
	}

	for _, test in ipairs(tests) do
		it("should parse " .. test.name, function()
			assert.are.same(test.expected, diff.parse_hunks(test.input))
		end)
	end
end)
