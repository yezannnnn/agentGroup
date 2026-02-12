import React from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import styles from './FeatureCard.module.css';

interface FeatureCardProps {
  title: string;
  description: string;
  icon: string;
  to: string;
}

export default function FeatureCard({ title, description, icon, to }: FeatureCardProps): JSX.Element {
  return (
    <Link className={clsx('card', styles.featureCard)} to={to}>
      <div className={styles.featureIcon}>{icon}</div>
      <div className="card__body">
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
    </Link>
  );
}
