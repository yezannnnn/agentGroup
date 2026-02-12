import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    { type: 'doc', id: 'introduction', label: 'Introduction' },
    {
      type: 'category',
      label: 'Principles',
      items: [
        'Principles/context-engineering',
        'Principles/specs-driven-development',
      ],
    },
    {
      type: 'category',
      label: 'Getting Started',
      items: [
        'legacy-installation',
        'mcp-installation',
      ],
    },
    {
      type: 'category',
      label: 'Legacy System',
      items: [
        'legacy-overview',
        'legacy-architecture',
        'legacy-workflow',
        {
          type: 'category',
          label: 'Command Reference',
          items: [
            'do_task',
            'initialize',
          ],
        },
      ],
    },
    {
      type: 'category',
      label: 'MCP Server',
      items: [
        'mcp-overview',
        'mcp-architecture',
        'mcp-workflow',
        'prompt-reference',
      ],
    },
  ],
};

export default sidebars;
