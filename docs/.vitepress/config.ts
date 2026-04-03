import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'zen-marketplace',
  description: 'Structured development plugins for Claude Code — zenflow, agent-journal, and total-recall.',

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
          { text: 'Agent Journal', link: '/plugins/agent-journal/' },
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
          { text: 'The Pipeline', link: '/plugins/zenflow/pipeline' },
          { text: 'Skills Reference', link: '/plugins/zenflow/skills' },
          { text: 'Agents', link: '/plugins/zenflow/agents' },
          { text: 'Hooks', link: '/plugins/zenflow/hooks' },
          { text: 'Configuration', link: '/plugins/zenflow/configuration' },
          { text: 'Workflows & Diagrams', link: '/plugins/zenflow/workflows' },
        ],
      },
      {
        text: 'Agent Journal',
        collapsed: false,
        items: [
          { text: 'Overview', link: '/plugins/agent-journal/' },
          { text: 'Entry Schema', link: '/plugins/agent-journal/schema' },
          { text: 'Reading & Filtering', link: '/plugins/agent-journal/usage' },
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
