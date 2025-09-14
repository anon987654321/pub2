// eslint.config.mjs - Basic ESLint v9 configuration
export default [
  {
    files: ["**/*.js"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "commonjs",
      globals: {
        console: "readonly",
        process: "readonly",
        require: "readonly",
        module: "readonly",
        exports: "readonly",
        __dirname: "readonly",
        __filename: "readonly",
        Buffer: "readonly",
        global: "readonly",
      },
    },
    rules: {
      // Only error-level rules per v64.0.1 gating policy
      "no-undef": "error",
      "no-unused-vars": "error", 
      "no-redeclare": "error",
    },
  },
];