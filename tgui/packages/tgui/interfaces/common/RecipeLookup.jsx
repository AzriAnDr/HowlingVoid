import {
  Box,
  Button,
  Chart,
  Flex,
  Icon,
  LabeledList,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';

export const RecipeLookup = (props) => {
  const { recipe, bookmarkedReactions } = props;
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  if (!recipe) {
    return <Box>{t('ui.recipe_lookup.no_reaction_selected')}</Box>;
  }

  const getReaction = (id) => {
    return data.master_reaction_list.filter((reaction) => reaction.id === id);
  };

  const addBookmark = (bookmark) => {
    bookmarkedReactions.add(bookmark);
  };

  return (
    <LabeledList>
      <LabeledList.Item bold label={t('ui.common.recipe')}>
        <Icon name="circle" mr={1} color={recipe.reagentCol} />
        {recipe.name}
        <Button
          icon="arrow-left"
          ml={3}
          disabled={recipe.subReactIndex === 1}
          onClick={() =>
            act('reduce_index', {
              id: recipe.name,
            })
          }
        />
        <Button
          icon="arrow-right"
          disabled={recipe.subReactIndex === recipe.subReactLen}
          onClick={() =>
            act('increment_index', {
              id: recipe.name,
            })
          }
        />
        {bookmarkedReactions && (
          <Button
            icon="book"
            color="green"
            disabled={bookmarkedReactions.has(getReaction(recipe.id)[0])}
            onClick={() => {
              addBookmark(getReaction(recipe.id)[0]);
              act('update_ui');
            }}
          />
        )}
      </LabeledList.Item>
      {recipe.products && (
        <LabeledList.Item bold label={t('ui.common.products')}>
          {recipe.products.map((product) => (
            <Button
              key={product.name}
              icon="vial"
              disabled={product.hasProduct}
              content={`${product.ratio}u ${product.name}`}
              onClick={() =>
                act('reagent_click', {
                  id: product.id,
                })
              }
            />
          ))}
        </LabeledList.Item>
      )}
      <LabeledList.Item bold label={t('ui.common.reactants')}>
        {recipe.reactants.map((reactant) => (
          <Box key={reactant.id}>
            <Button
              icon="vial"
              color={reactant.color}
              content={`${reactant.ratio}u ${reactant.name}`}
              onClick={() =>
                act('reagent_click', {
                  id: reactant.id,
                })
              }
            />
            {!!reactant.tooltipBool && (
              <Button
                icon="flask"
                color="purple"
                tooltip={reactant.tooltip}
                tooltipPosition="right"
                onClick={() =>
                  act('find_reagent_reaction', {
                    id: reactant.id,
                  })
                }
              />
            )}
          </Box>
        ))}
      </LabeledList.Item>
      {recipe.catalysts && (
        <LabeledList.Item bold label={t('ui.common.catalysts')}>
          {recipe.catalysts.map((catalyst) => (
            <Box key={catalyst.id}>
              {(catalyst.tooltipBool && (
                <Button
                  icon="vial"
                  color={catalyst.color}
                  content={`${catalyst.ratio}u ${catalyst.name}`}
                  tooltip={catalyst.tooltip}
                  tooltipPosition={'right'}
                  onClick={() =>
                    act('reagent_click', {
                      id: catalyst.id,
                    })
                  }
                />
              )) || (
                <Button
                  icon="vial"
                  color={catalyst.color}
                  content={`${catalyst.ratio}u ${catalyst.name}`}
                  onClick={() =>
                    act('reagent_click', {
                      id: catalyst.id,
                    })
                  }
                />
              )}
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {recipe.reqContainer && (
        <LabeledList.Item bold label={t('ui.common.container')}>
          <Button
            color="transparent"
            textColor="white"
            tooltipPosition="right"
            content={recipe.reqContainer}
            tooltip={t('ui.recipe_lookup.required_container_tooltip')}
          />
        </LabeledList.Item>
      )}
      <LabeledList.Item bold label={t('ui.common.purity')}>
        <LabeledList>
          <LabeledList.Item label={t('ui.recipe_lookup.optimal_ph_range')}>
            <Box position="relative">
              <Tooltip content={t('ui.recipe_lookup.tooltip_optimal_ph_range')}>
                {`${recipe.lowerpH}-${recipe.upperpH}`}
              </Tooltip>
            </Box>
          </LabeledList.Item>
          {!!recipe.inversePurity && (
            <LabeledList.Item label={t('ui.recipe_lookup.inverse_purity')}>
              <Box position="relative">
                <Tooltip content={t('ui.recipe_lookup.tooltip_inverse_purity')}>
                  {`<${recipe.inversePurity * 100}%`}
                </Tooltip>
              </Box>
            </LabeledList.Item>
          )}
          {!!recipe.minPurity && (
            <LabeledList.Item label={t('ui.recipe_lookup.minimum_purity')}>
              <Box position="relative">
                <Tooltip content={t('ui.recipe_lookup.tooltip_minimum_purity')}>
                  {`<${recipe.minPurity * 100}%`}
                </Tooltip>
              </Box>
            </LabeledList.Item>
          )}
        </LabeledList>
      </LabeledList.Item>
      <LabeledList.Item bold label={t('ui.recipe_lookup.rate_profile')} width="10px">
        <Box
          height="50px"
          position="relative"
          style={{
            backgroundColor: 'black',
          }}
        >
          <Chart.Line
            fillPositionedParent
            data={recipe.thermodynamics}
            strokeWidth={0}
            fillColor={'#3cf072'}
          />
          {recipe.explosive && (
            <Chart.Line
              position="absolute"
              justify="right"
              top={0.01}
              bottom={0}
              right={recipe.isColdRecipe ? null : 0}
              width="28px"
              data={recipe.explosive}
              strokeWidth={0}
              fillColor={'#d92727'}
            />
          )}
        </Box>
        <Flex justify="space-between">
          <Tooltip
            content={
              recipe.isColdRecipe
                ? 'The temperature at which it is underheated, causing negative effects on the reaction.'
                : 'The minimum temperature needed for this reaction to start. Heating it up past this point will increase the reaction rate.'
            }
          >
            <Flex.Item
              position="relative"
              textColor={recipe.isColdRecipe && 'red'}
            >
              {recipe.isColdRecipe
                ? `${recipe.explodeTemp}K`
                : `${recipe.tempMin}K`}
            </Flex.Item>
          </Tooltip>

          {recipe.explosive && (
            <Tooltip
              content={
                recipe.isColdRecipe
                  ? 'The minimum temperature needed for this reaction to start. Heating it up past this point will increase the reaction rate.'
                  : 'The temperature at which it is overheated, causing negative effects on the reaction.'
              }
            >
              <Flex.Item
                position="relative"
                textColor={!recipe.isColdRecipe && 'red'}
              >
                {recipe.isColdRecipe
                  ? `${recipe.tempMin}K`
                  : `${recipe.explodeTemp}K`}
              </Flex.Item>
            </Tooltip>
          )}
        </Flex>
      </LabeledList.Item>
      <LabeledList.Item bold label={t('ui.recipe_lookup.dynamics')}>
        <LabeledList>
          <LabeledList.Item label={t('ui.recipe_lookup.optimal_rate')}>
            <Tooltip content={t('ui.recipe_lookup.tooltip_optimal_rate')}>
              <Box position="relative">{`${recipe.thermoUpper}u/s`}</Box>
            </Tooltip>
          </LabeledList.Item>
        </LabeledList>
        <Tooltip content={t('ui.recipe_lookup.tooltip_thermics')}>
          <Box position="relative">{recipe.thermics}</Box>
        </Tooltip>
      </LabeledList.Item>
    </LabeledList>
  );
};
