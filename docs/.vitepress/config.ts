import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'zen-marketplace',
  description: 'Structured development plugins for Claude Code — zenflow, field-notes, and total-recall.',
  base: '/zen-flow/',
  appearance: 'dark',

  themeConfig: {
    logo: '⚡',
    siteTitle: 'zen-marketplace',

    nav: [
      { text: 'Home', link: '/' },
      { text: 'Getting Started', link: '/getting-started' },
      {
        text: 'Plugins',
        items: [
          { text: 'ZenFlow', link: '/plugins/zenflow/' },
          { text: 'Field Notes', link: '/plugins/field-notes/' },
          { text: 'Total Recall', link: '/plugins/total-recall/' },
        ],
      },
    ],

    sidebar: [
      {
        text: 'Introduction',
        items: [
          { text: 'What is zen-marketplace?', link: '/' },
          { text: 'Getting Started', link: '/getting-started' },
        ],
      },
      {
        text: 'ZenFlow',
        collapsed: false,
        items: [
          { text: 'Overview', link: '/plugins/zenflow/' },
          { text: 'Philosophy', link: '/plugins/zenflow/philosophy' },
          { text: 'Philosophy (Agent)', link: '/plugins/zenflow/philosophy-agent' },
          { text: 'The Pipeline', link: '/plugins/zenflow/pipeline' },
          { text: 'Collab', link: '/plugins/zenflow/collab' },
          { text: 'Skills Reference', link: '/plugins/zenflow/skills' },
          { text: 'Agents', link: '/plugins/zenflow/agents' },
          { text: 'Hooks', link: '/plugins/zenflow/hooks' },
          { text: 'Configuration', link: '/plugins/zenflow/configuration' },
          { text: 'Workflows & Diagrams', link: '/plugins/zenflow/workflows' },
        ],
      },
      {
        text: 'Field Notes',
        collapsed: false,
        items: [
          { text: 'Overview', link: '/plugins/field-notes/' },
          { text: 'Entry Schema', link: '/plugins/field-notes/schema' },
          { text: 'Reading & Filtering', link: '/plugins/field-notes/usage' },
          { text: 'Workflows & Diagrams', link: '/plugins/field-notes/workflows' },
        ],
      },
      {
        text: 'Total Recall',
        collapsed: false,
        items: [
          { text: 'Overview', link: '/plugins/total-recall/' },
          { text: 'How It Works', link: '/plugins/total-recall/how-it-works' },
          { text: 'Test Results', link: '/plugins/total-recall/test-results' },
        ],
      },
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/brewpirate/zen-flow' },
    ],

    search: {
      provider: 'local',
    },

    footer: {
      message: 'Experimental — APIs and behavior may change without notice.',
    },
  },

  vite: {
    ssr: {
      noExternal: ['vitepress-carbon'],
    },
  },

  markdown: {
    theme: {
      light: 'one-dark-pro',
      dark: 'one-dark-pro',
    },
  },
})
